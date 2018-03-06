from math import ceil, log2
import numpy as np


__author__ = "Yun Rock Qu"
__email__ = "yunq@xilinx.com"


def get_numpy_data_type(num_bits_per_field):
    if 0 < num_bits_per_field <= 8:
        return np.uint8
    elif num_bits_per_field <= 16:
        return np.uint16
    elif num_bits_per_field <= 32:
        return np.uint32
    else:
        raise ValueError('Currently only support at most 32 bits per field.')


class SoftwareDecisionTree:
    def __init__(self, num_fields, num_bits_per_field, num_levels):
        self.num_fields = num_fields
        self.num_bits_per_field = num_bits_per_field
        self.num_levels = num_levels
        self.tree_list = np.zeros((1 << num_levels) - 1,
                                  dtype=get_numpy_data_type(
                                      num_bits_per_field))
        self.index_list = np.zeros((1 << num_levels) - 1,
                                   dtype=get_numpy_data_type(
                                       ceil(log2(num_fields))))
        self.in_buffer = None
        self.out_buffer = None

    def next_hop(self, address, data):
        field_index = self.index_list[address]
        mask = (1 << (
            self.num_bits_per_field * (self.num_fields - field_index))) - (
            1 << (
                self.num_bits_per_field * (self.num_fields - field_index - 1)))
        data_compare = (data & mask) >> (
            self.num_bits_per_field * (self.num_fields - field_index - 1))
        if data_compare == self.tree_list[address]:
            return 2 * address + 1
        else:
            return 2 * address + 2

    def binary_search(self, data, address=0):
        if address >= 1 << (self.num_levels - 1):
            return address
        else:
            address = self.next_hop(address, data)
            return self.binary_search(data, address)

    def load_sw(self, address, field_index, node_value):
        self.tree_list[address] = node_value
        self.index_list[address] = field_index

    def prepare_sw(self, data_batch):
        length = len(data_batch)
        self.in_buffer = np.zeros(shape=length, dtype=np.uint32)
        self.out_buffer = np.zeros(shape=length, dtype=np.uint32)
        for i, data in enumerate(data_batch):
            for field_index in data:
                self.in_buffer[i] |= (
                    data[field_index] << (
                        (self.num_fields - 1 - field_index) *
                        self.num_bits_per_field))

    def search_sw(self):
        for i, j in enumerate(self.in_buffer):
            self.out_buffer[i] = self.binary_search(j)
        return self.out_buffer
