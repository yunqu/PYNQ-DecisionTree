from math import ceil, log2
import numpy as np
from pynq import Xlnk


__author__ = "Yun Rock Qu"
__email__ = "yunq@xilinx.com"


class HardwareDecisionTree:
    def __init__(self, overlay, num_fields, num_bits_per_field, num_levels):
        self.num_fields = num_fields
        self.num_bits_per_field = num_bits_per_field
        self.num_levels = num_levels
        self.tree_ctrl = overlay.binary_tree
        self.dma = overlay.dma
        self.xlnk = Xlnk()
        self.in_buffer = None
        self.out_buffer = None
        self.reset()

    def reset(self):
        # reset contiguous memory
        self.xlnk.xlnk_reset()
        # assert and de-assert reset
        self.tree_ctrl.write(0x0, 0x01)
        self.tree_ctrl.write(0x0, 0x00)

    def get_address_bits(self, regs, address):
        level = int(ceil(log2(address + 2)) - 1)
        ram_address = address - ((1 << level) - 1)

        def get_addr_bit_location(n):
            if n == 0:
                return [0, 0]
            else:
                result = 1
                for j in range(n):
                    result += j
                return [result, result+n-1]

        msb, lsb = get_addr_bit_location(level)
        _, final = get_addr_bit_location(self.num_levels - 1)
        total = final + 1
        mask = (1 << (total - msb)) - (1 << (total - lsb - 1))

        masked_address = (ram_address << (total - lsb - 1)) & mask
        reg_value = (regs[3] << 96) + (regs[2] << 64) + (regs[1] << 32) + regs[
            0]
        reg_value &= ~mask
        reg_value |= masked_address
        for i in range(4):
            regs[i] = (reg_value >> (32 * i)) & ((1 << 32) - 1)
        return regs

    def get_field_bits(self, regs, address, field_index):
        num_bits_per_field_index = ceil(log2(self.num_fields))
        level = ceil(log2(address + 2)) - 1

        def get_field_bit_location(n):
            return [n * num_bits_per_field_index,
                    (n + 1) * num_bits_per_field_index - 1]

        msb, lsb = get_field_bit_location(level)
        _, final = get_field_bit_location(self.num_levels - 1)
        total = final + 1
        mask = (1 << (total - msb)) - (1 << (total - lsb - 1))

        masked_field_index = (field_index << (total - lsb - 1)) & mask
        reg_value = (regs[3] << 96) + (regs[2] << 64) + (regs[1] << 32) + regs[
            0]
        reg_value = reg_value & ~mask
        reg_value = reg_value | masked_field_index
        for i in range(4):
            regs[i] = (reg_value >> (32 * i)) & ((1 << 32) - 1)
        return regs

    def get_node_bits(self, regs, address, node_value):
        level = ceil(log2(address + 2)) - 1

        def get_node_bit_location(n):
            return [n * self.num_bits_per_field,
                    (n + 1) * self.num_bits_per_field - 1]

        msb, lsb = get_node_bit_location(level)
        _, final = get_node_bit_location(self.num_levels - 1)
        total = final + 1
        mask = (1 << (total - msb)) - (1 << (total - lsb - 1))

        masked_node = (node_value << (total - lsb - 1)) & mask
        reg_value = (regs[3] << 96) + (regs[2] << 64) + (regs[1] << 32) + regs[
            0]
        reg_value &= ~mask
        reg_value |= masked_node
        for i in range(4):
            regs[i] = (reg_value >> (32 * i)) & ((1 << 32) - 1)
        return regs

    def set_address(self, address):
        # RAM address registers 9 - 12
        read_values = [self.tree_ctrl.read(0x4 * i) for i in range(9, 13)]
        write_values = self.get_address_bits(read_values, address)
        [self.tree_ctrl.write(0x4 * i, write_values[i - 9]) for i in
         range(9, 13)]

    def set_field_index(self, address, field_index):
        # field index registers 5 - 8
        read_values = [self.tree_ctrl.read(0x4 * i) for i in range(5, 9)]
        write_values = self.get_field_bits(read_values, address, field_index)
        [self.tree_ctrl.write(0x4 * i, write_values[i - 5]) for i in
         range(5, 9)]

    def set_node_value(self, address, node_value):
        # node value registers 1 - 4
        read_values = [self.tree_ctrl.read(0x4 * i) for i in range(1, 5)]
        write_values = self.get_node_bits(read_values, address, node_value)
        [self.tree_ctrl.write(0x4 * i, write_values[i - 1]) for i in
         range(1, 5)]

    def load_hw(self, address, field_index, node_value):
        # read, modify, and write node value, field index, and address
        self.set_node_value(address, node_value)
        self.set_field_index(address, field_index)
        self.set_address(address)

        # assert and de-assert load
        self.tree_ctrl.write(0x0, 0x02)
        self.tree_ctrl.write(0x0, 0x00)

    def show_ctrl_registers(self):
        for i in range(1, 13):
            print('Slave register{}: {}'.format(
                i, hex(self.tree_ctrl.read(0x4 * i))))

    def prepare_hw(self, data_batch):
        length = len(data_batch)
        self.in_buffer = self.xlnk.cma_array(shape=length, dtype=np.uint32)
        self.out_buffer = self.xlnk.cma_array(shape=length, dtype=np.uint32)
        for i, data in enumerate(data_batch):
            for field_index in data:
                self.in_buffer[i] |= (
                    data[field_index] << (
                        (self.num_fields - 1 - field_index) *
                        self.num_bits_per_field))

    def search_hw(self):
        self.dma.sendchannel.transfer(self.in_buffer)
        self.dma.recvchannel.transfer(self.out_buffer)
        self.dma.sendchannel.wait()
        self.dma.recvchannel.wait()
        return self.out_buffer
