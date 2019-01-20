from setuptools import setup, find_packages
import shutil
import sys
import os


__author__ = "Yun Rock Qu"
__email__ = "yunq@xilinx.com"


GIT_DIR = os.path.dirname(os.path.realpath(__file__))


# Notebook delivery
def fill_notebooks():
    src_nb = GIT_DIR + '/notebooks'
    dst_nb_dir = '/home/xilinx/jupyter_notebooks/decision_tree'
    if os.path.exists(dst_nb_dir):
        shutil.rmtree(dst_nb_dir)
    shutil.copytree(src_nb, dst_nb_dir)

    print("Filling notebooks done ...")


if len(sys.argv) > 1 and sys.argv[1] == 'install':
    fill_notebooks()


def package_files(directory):
    paths = []
    for (path, directories, file_names) in os.walk(directory):
        for file_name in file_names:
            paths.append(os.path.join('..', path, file_name))
    return paths


extra_files = package_files('pynq_decision_tree')


setup(name='pynq_decision_tree',
      version='2.4',
      description='PYNQ decision tree package',
      author='Yun Rock Qu',
      author_email='yunq@xilinx.com',
      url='https://github.com/yunqu/PYNQ-DecisionTree',
      packages=find_packages(),
      download_url='https://github.com/yunqu/PYNQ-DecisionTree',
      package_data={
          '': extra_files,
      }
      )
