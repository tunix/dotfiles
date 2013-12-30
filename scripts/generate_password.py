#!/usr/bin/env python
# coding: utf-8
# 
# @author: Alper KANAT <alperkanat@raptiye.org>

from random import sample
import string

print("".join(sample(string.ascii_letters + string.digits, 10)))
