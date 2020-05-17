#!/usr/bin/env python
# coding: utf-8
#
# @author: Alper Kanat <me@alperkan.at>

from random import sample
import string

print("".join(sample(string.ascii_letters + string.digits, 10)))
