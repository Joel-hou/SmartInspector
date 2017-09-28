#!/usr/bin/env python
# modify app route if necessary
import argparse
from flask import Flask
from flask import request
import json
import os
# logger.py in the same directory
import logger as doctor_log
import time

LOG = doctor_log.Logger('doctor_consumer').getLogger()

app = Flask(__name__)

# app route should be the same with your alarm event url
@app.route('/', methods=['POST'])
def event_posted():
    LOG.info('application manager notified at %s' % time.time())
    LOG.info('received data = %s' % request.data)
    d = json.loads(request.data)
    return "OK"


def get_args():
    parser = argparse.ArgumentParser(description='Doctor Sample Application manager')
    parser.add_argument('port', metavar='PORT', type=int, nargs='?',
                        help='the port for application manager')
    return parser.parse_args()


def main():
    args = get_args()
    app.run(host="0.0.0.0", port=args.port)


if __name__ == '__main__':
    main()
