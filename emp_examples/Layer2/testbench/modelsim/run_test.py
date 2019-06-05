from optparse import OptionParser
import yaml
from subprocess import call
import pandas
import sys
import os

def test(yamlConfig):
  print("Writing tcl file top_simulate.do")

  if not os.path.exists("modelsim_lib"):
    os.mkdir("modelsim_lib")

  if not os.path.exists("DebuggingOutput"):
    os.mkdir("DebuggingOutput")

  with open('top_simulate.do', 'w') as dofile:
    dofile.write("do {top_compile.do}\n")
    dofile.write('vsim -G/top/g1/MP7CaptureFileReaderInstance/FileName="{}" -GDebugInstance/FilePath="{}/" -voptargs="+acc" -L Utilities -L PFChargedObj -L Layer2 -L Interfaces -L Utilities -lib xil_defaultlib Layer2.top\n'.format(yamlConfig['PatternFile'], yamlConfig['DebuggingOutputDir']))
    #dofile.write('vsim -GDebugInstance/FilePath="{}/" -voptargs="+acc" -L Utilities -L PFChargedObj -L Layer2 -L Interfaces -L Utilities -lib xil_defaultlib Layer2.top\n'.format(yamlConfig['DebuggingOutputDir']))
    dofile.write('set NumericStdNoWarnings 1\n')
    dofile.write('set StdArithNoWarnings 1\n')

    runtime = 1.2 * (yamlConfig['nEvents']+1) * yamlConfig['EventLength'] * yamlConfig['clkPeriod']
    dofile.write('run {} ns\n'.format(runtime)) 
    dofile.write('quit -f\n')
    dofile.close()

  # Run the simulation
  print("Running Modelsim")
  call(["vsim", "-batch", "-do", "top_simulate.do"])

 ## Config module
def parse_config(config_file) :

    print("Loading configuration from " + str(config_file))
    config = open(config_file, 'r')
    return yaml.load(config)

if __name__ == "__main__":
  parser = OptionParser()
  parser.add_option('-c','--config'   ,action='store',type='string', dest='config', default='sim_config.yml', help='configuration file')
  (options, args) = parser.parse_args()

  yamlConfig = parse_config(options.config)

  test(yamlConfig)
  success = 0
  sys.exit(success)

 
