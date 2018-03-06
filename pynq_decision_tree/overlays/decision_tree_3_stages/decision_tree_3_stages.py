import pynq


__author__ = "Yun Rock Qu"
__email__ = "yunq@xilinx.com"


class DecisionTree3StagesOverlay(pynq.Overlay):
    """ The decision tree overlay for Pynq-Z1

    This overlay is designed for C4.5 decision tree, where data can have
    multiple fields. This overlay supports a multi-stage pipelined tree 
    structure.

    Attributes
    ----------
    binary_tree : dict
         A dict with IP information for the binary tree pipeline.
    dma : dict
        A dict storing the DMA information.

    """

    def __init__(self, bitfile, **kwargs):
        super().__init__(bitfile, **kwargs)
        if self.is_loaded():
            self.binary_tree = self.binary_tree_0
            self.dma = self.axi_dma_0
