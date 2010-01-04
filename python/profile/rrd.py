#!/usr/bin/env python
# Corey Goldberg - Dec 2009

import os
import time
from subprocess import Popen, PIPE, STDOUT



class RRD(object):
    def __init__(self, rrd_name):
        self.rrd_exe = 'rrdtool'
        self.subdir = ''        
        self.rrd_name = rrd_name
        self.graph_width = 500
        self.graph_height = 175
        

    def create_rrd(self, interval, ds_type='GAUGE'):  
        interval = str(interval) 
        interval_mins = float(interval) / 60  
        heartbeat = str(int(interval) * 2)
        ds_string1 = ' DS:d1:%s:%s:U:U' % (ds_type, heartbeat)
        ds_string2 = ' DS:d2:%s:%s:U:U' % (ds_type, heartbeat)
        ds_string3 = ' DS:d3:%s:%s:U:U' % (ds_type, heartbeat)
        cmd_create = ''.join((self.rrd_exe, 
            ' create ', self.rrd_name, ' --step ', interval, ds_string1, ds_string2, ds_string3,
            ' RRA:AVERAGE:0.5:1:', str(int(4000 / interval_mins)),
            ' RRA:AVERAGE:0.5:', str(int(30 / interval_mins)), ':800',
            ' RRA:AVERAGE:0.5:', str(int(120 / interval_mins)), ':800',
            ' RRA:AVERAGE:0.5:', str(int(1440 / interval_mins)), ':800'))
        cmd_args = cmd_create.split(' ')
        p = Popen(cmd_args, stdout=PIPE, stderr=STDOUT, shell=False)
        cmd_output = p.stdout.read()
        if len(cmd_output) > 0:
            raise RRDException('Unable to create RRD: ' + cmd_output.rstrip())
        
  
    def update(self, vals):
        cmd_update = '%s update %s N:%i:%i:%i' % (self.rrd_exe, self.rrd_name, vals[0], vals[1], vals[2])
        cmd_args = cmd_update.split(' ')
        p = Popen(cmd_args, stdout=PIPE, stderr=STDOUT, shell=False)
        cmd_output = p.stdout.read()
        if len(cmd_output) > 0:
            raise RRDException('Unable to update RRD: ' + cmd_output.rstrip())
    
    
    def graph(self, mins):       
        start_time = 'now-%s' % (mins * 60)  
        output_filename = '%s_%i.png' % (self.rrd_name, mins)
        end_time = 'now'
        ds_name1 = 'd1'
        ds_name2 = 'd2'
        ds_name3 = 'd3'
        cur_date = time.strftime('%m/%d/%Y %H\:%M\:%S', time.localtime())    
        
        cmd = [self.rrd_exe, 'graph', self.subdir + output_filename]
        cmd.append('COMMENT:\\s')
        cmd.append('COMMENT:\\s')
        cmd.append('COMMENT:%s' % cur_date)
        cmd.append('COMMENT:\\s')
        cmd.append('COMMENT:\\s')
        cmd.append('COMMENT:\\s')
        cmd.append('COMMENT:average latency\\:\\s')
        cmd.append('COMMENT:\\s')
            
        cmd.append('DEF:' + ds_name3 + '=' + self.rrd_name + ':' + ds_name3 + ':AVERAGE')
        cmd.append('AREA:' + ds_name3 + '#FF3333:content transferred')
        cmd.append('VDEF:' + ds_name3 + 'last=' + ds_name3 + ',LAST')
        cmd.append('VDEF:' + ds_name3 + 'avg=' + ds_name3 + ',AVERAGE')
        cmd.append('GPRINT:' + ds_name3 + 'avg:...%.0lfms')
        cmd.append('COMMENT:\\s')
        cmd.append('COMMENT:\\s')
        
        cmd.append('DEF:' + ds_name2 + '=' + self.rrd_name + ':' + ds_name2 + ':AVERAGE')
        cmd.append('AREA:' + ds_name2 + '#FF9933:response received')
        cmd.append('VDEF:' + ds_name2 + 'last=' + ds_name2 + ',LAST')
        cmd.append('VDEF:' + ds_name2 + 'avg=' + ds_name2 + ',AVERAGE')
        cmd.append('GPRINT:' + ds_name2 + 'avg:.....%.0lfms')
        cmd.append('COMMENT:\\s')
        cmd.append('COMMENT:\\s')
        
        cmd.append('DEF:' + ds_name1 + '=' + self.rrd_name + ':' + ds_name1 + ':AVERAGE')
        cmd.append('AREA:' + ds_name1 + '#FFFF66:request sent')
        cmd.append('VDEF:' + ds_name1 + 'last=' + ds_name1 + ',LAST')
        cmd.append('VDEF:' + ds_name1 + 'avg=' + ds_name1+ ',AVERAGE')
        cmd.append('GPRINT:' + ds_name1 + 'avg:..........%.0lfms')
        cmd.append('COMMENT:\\s')
        cmd.append('COMMENT:\\s')
            
        cmd.append('--title=' + self.rrd_name.replace('.rrd', ''))
        cmd.append('--vertical-label=Response Time (milliseconds)')
        cmd.append('--start=' + start_time)
        cmd.append('--end=' + end_time)
        cmd.append('--width=' + str(self.graph_width))
        cmd.append('--height=' + str(self.graph_height))
        cmd.append('--slope-mode')
        cmd.append('--lower-limit=0')
           
        p = Popen(cmd, stdout=PIPE, stderr=STDOUT, shell=False)
        cmd_output = p.stdout.read()
        if len(cmd_output) > 10:
            raise RRDException('Unable to graph RRD: ' + cmd_output.rstrip())
            
          
          
class RRDException(Exception): pass
