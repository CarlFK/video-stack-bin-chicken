#!/usr/bin/python

# save-hostname.py - called from dnsmasq --dhcp-script=save-hostname.py

"""
man dnsmasq
--dhcp-script=<path>
  Whenever a new DHCP lease is created, or an old  one  destroyed,
  or  a  TFTP file transfer completes, the executable specified by
  this option is run.  <path> must be  an  absolute  pathname,  no
  PATH  search  occurs.   The  arguments to the process are "add",
  "old" or "del", the MAC address of the host (or DUID for IPv6) ,
  the  IP address, and the hostname, if known. "add" means a lease
  has been created, "del" means it has been destroyed, "old" is  a
  notification  of  an  existing  lease  when  dnsmasq starts or a
  change to MAC address or hostname of an  existing  lease  (also,
  lease  length  or expiry and client-id, if leasefile-ro is set).
  If the MAC address is from a network type other  than  ethernet,
  it    will    have    the    network    type    prepended,    eg
  "06-01:23:45:67:89:ab" for token ring. The  process  is  run  as
  root  (assuming that dnsmasq was originally run as root) even if
  dnsmasq is configured to change UID to an unprivileged user.

  The environment is inherited from the invoker of  dnsmasq,  with
  some or all of the following variables added

  If the client provides a hostname, DNSMASQ_SUPPLIED_HOSTNAME

    dhcp-host=mac,ip,hostname
    /etc/dnsmasq.d/, which is included in my dnsmasq conf:
    dnsmasq ... --conf-dir=/etc/dnsmasq.d

  See --dhcp-hostsdir for a way of getting new host entries read
  automatically.

 Primary key in leases database is IP, to "add" happens when IP address
 is new, "old" for existing IP address, but other data changes.

  and where the hostname comes from (client or server)

  either, if both available, server overrides.


"""

import argparse
import os

DEBUG=True

# load up the file with "old" data.
# Set to False to only react to "new" data.
INIT=True

def ck_file(args):

    """
    for lines that start with dhcp-host=
    look for mac after = and remove anyything after the first comma
    if the passed mac is found, return True
    """

    try:
        for l in open(args.filename).read().split('\n'):
            if l.startswith("dhcp-host="):
                values=l.split('=')[1]
                mac = values.split(',',1)[0]
                if mac == args.mac:
                    return True
    except IOError:
        return False

    return False

def add_to_file(args):
    with open(args.filename,'a') as f:
        lines='\n# {hostname}\n' \
            'dhcp-host={mac},set:{hostname},{hostname}\n'.format(
i                  mac=args.mac, ip=args.ip, hostname=args.hostname)
        f.write(lines)

def add_maybe(args):

    """
    if there is a hostname to save
      and the mac is not in the file:
          add the mac:hostnampa.
    """

    if args.hostname is not None \
            and not ck_file(args):
        add_to_file(args)


def get_args():

    """
    The  arguments to the process are
    action: one of ["add", "old", "del"],
    MAC address of the host (or DUID for IPv6) ,
    IP address,
    hostname, if known.
    """

    parser = argparse.ArgumentParser(
            description="""called from dnsmasq""")

    parser.add_argument('action',
            help='What the server is doing.')

    parser.add_argument('mac',
            help='MAC address of the host.')

    parser.add_argument('ip',
            help='ip addresst.')

    parser.add_argument('hostname',
            nargs='?',
            default=None)

    parser.add_argument('--filename',
            default="/etc/dnsmasq.d/macs.cfg",
            help='File to save mac/hostnames (overide for testing)')

    args = parser.parse_args()

    return args


def main():
    args = get_args()

    if DEBUG:
	with open('/tmp/foo','a') as f:
	    f.write(args.__repr__())
	    f.write('\n')
            f.write(os.getenv('DNSMASQ_SUPPLIED_HOSTNAME', "oh no!"))
	    f.write('\n')

    if args.action == "add":
        add_maybe(args)
    elif (args.action == "old") and INIT:
        add_maybe(args)

if __name__ == "__main__":
    main()

