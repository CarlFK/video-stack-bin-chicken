#!/usr/bin/python3

# parse_dnsmasq_conf.py
# tries to parse the conf file

import argparse
import os
from pprint import pprint
import re


def parse_file(filename):

    """
    for lines that start with dhcp-foo
    """
    line_re = re.compile(
            r"^dhcp-(?P<key>[\w\-]*)=(?P<value>.*)$")
            # r"^dhcp-(?P<key>[\w\-]*)=(?P<value>.*)(?P<comment>#.*)?$")

    boxes={}

    for l in open(filename).read().split('\n'):
        # print(l)
        l = l.split('#',1)[0].strip()
        lx = line_re.search(l)
        if lx is not None:
            kv = lx.groupdict()
            # print(kv)
            vs = kv['value'].split(',')
            # print(vs)

            if len(vs)==2:
                # default line
                continue

            if kv['key']=='host':
                boxes[vs[2]] = {
                        'mac': vs[0],
                        # 'comment':kv['comment'],
                        }

            elif kv['key']=='option-force':
                # ['tag:cnt6', '209', '"partman-auto/disk=/dev/sdb grub-installer/bootdev=/dev/sdb tasks="']
                hostname = vs[0].split(':')[1]
                # unpack the appends
                appends = vs[2].strip('"')
                # print(appends)
                for append in appends.split():
                    # print(append)
                    k,v=append.split('=')
                    if k == "partman-auto/disk":
                        # partman-auto/disk=/dev/sdb
                        boxes[hostname]['disk'] = v
                    elif k == "tasks":
                        # tasks=ubuntu-desktop
                        boxes[hostname]['tasks'] = v

    return boxes

def mk_yml(boxes):
    """
boxes:
- hostname:
  mac:
  ip:
  disk:
  tasks:
  comment:
"""
    print("boxes:")
    for box in sorted(boxes):
        print("- hostname: {}".format(box))
        boxd = boxes[box]
        for key in [
              'mac', 'ip', 'disk', 'tasks', 'comment',
              ]:
            if key in boxd:
                print( "  {key}: {value}".format( key=key, value=boxd[key]))
        print()




def get_args():

    """
    The  arguments to the process are
    "add", "old" or "del",
    the MAC address of the host (or DUID for IPv6) ,
    the  IP address,
    and the hostname, if known.
    """

    parser = argparse.ArgumentParser(
            description="""called from dnsmasq""")

    parser.add_argument('--filename',
            default="/etc/dnsmasq.d/macs.cfg",
            help='File to save mac/hostnames (overide for testing)')

    args = parser.parse_args()

    return args


def main():
    args = get_args()

    boxes = parse_file('macs.conf')
    mk_yml(boxes)

if __name__ == "__main__":
    main()

