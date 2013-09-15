#!/usr/bin/python2.7
import subprocess
#mpcget = subprocess.Popen(["mpc", "current", "-f", "07%artist% ~ 03%title% 15From Album: 06%album%"], stdout=subprocess.PIPE)
#playing, err = mpcget.communicate()
#print "mew~ I'm listening to {0}".format(playing)
print "mew~ I'm listening to {}".format(subprocess.check_output(["mpc", "current", "-f", "07%artist% ~ 03%title% 15From Album: 06%album%"]))