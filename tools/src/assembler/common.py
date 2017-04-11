#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  common.py

import sys

def tryConvertNumber(number):

    result = 0
    if type(number) == int:
        return [True, number]

    if len(number) >= 2:

        try:
            if number[0:2] == '0x':
                result = int(number, 16)
                return [True, result]
            elif number[0:2] == '0b':
                result = int(number, 2)
                return [True, result]
            else:
                result = int(number, 10)
                return [True, result]
        except:
            return [False, result]

    else:
        try:
            result = int(number, 10)
            return [True, result]
        except:
            return [False, result]

def findSymbol(symbol_table, key):
    found = False
    value = 0
    relocation = False
    for item in symbol_table:
        if item.label == key:
            found = True
            value = item.address
            relocation = item.relocation
            break
    return [found, value, relocation]

def findSpecialSymbol(symbol_table, key):
    found = False
    value = 0
    mode = ""
    for item in symbol_table:
        if item.label == key:
            found = True
            value = item.address
            mode = item.mode
            break
    return [found, value, mode]

def trySolveImmediateOperand(instruction, symbol_table, special_symbol_table, key):

    #lets try if key is number
    result = tryConvertNumber(key)

    if result[0] == True: return [result[1], False, False]

    #try symbol table
    result = findSymbol(symbol_table, key)

    if result[0] == True:

        #if key is symbol, we have to get an number from it
        numberResult = tryConvertNumber(result[1])
        if numberResult[0] == True:
            return [numberResult[1], result[2], False]
        else:
            #symbol contain non int value, this is really really really bad :(
            print "Error! Instruction '" + instruction.opcode + "' at " + instruction.parrent.fileName + "@" + str(instruction.parrent.lineNumber) + ". Operand is supposed to be an symbol but symbol doesn't contain integer."
            sys.exit(1)

    #try special symbol table
    result = findSpecialSymbol(special_symbol_table, key)

    if result[0] == True:
         #if key is symbol, we have to get an number from it
        numberResult = tryConvertNumber(result[1])
        if numberResult[0] == True:
            return [numberResult[1], False, True]
        else:
            #symbol contain non int value, this is really really really bad :(
            print "Error! Instruction '" + instruction.opcode + "' at " + instruction.parrent.fileName + "@" + str(instruction.parrent.lineNumber) + ".  Operand is supposed to be an special symbol but symbol doesn't contain integer."
            sys.exit(1)


    #well... we don't know what key is => error
    print "Error! Instruction '" + instruction.opcode + "' at " + instruction.parrent.fileName + "@" + str(instruction.parrent.lineNumber) + ". Operand is not number or symbol."
    sys.exit(1)

def checkSizeOfImmediate(instruction, bits_limit, value):
    if value > ((2**bits_limit)-1):
        print "Warning! Instruction '" + instruction.opcode + "' at " + instruction.parrent.fileName + "@" + str(instruction.parrent.lineNumber) + ". Size of operand is larger than is allowed! It will be trimmed to right size!"
        return value & ((2**bits_limit)-1)
    else:
        return value
