#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#  common.py
#
#  Copyright 2017 Vladislav <vladislav.mlejnecky@student.upce.cz>

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

def decodeRegName(instruction, reg_name):
    reg = -1

    if   reg_name == "R0": reg = 0
    elif reg_name == "R1": reg = 1
    elif reg_name == "R2": reg = 2
    elif reg_name == "R3": reg = 3
    elif reg_name == "R4": reg = 4
    elif reg_name == "R5": reg = 5
    elif reg_name == "R6": reg = 6
    elif reg_name == "R7": reg = 7
    elif reg_name == "R8": reg = 8
    elif reg_name == "R9": reg = 9
    elif reg_name == "R10": reg = 10
    elif reg_name == "R11": reg = 11
    elif reg_name == "R12": reg = 12
    elif reg_name == "R13": reg = 13
    elif reg_name == "R14": reg = 14
    elif reg_name == "R15": reg = 15
    elif reg_name == "SP": reg = 14
    elif reg_name == "PC": reg = 15
    else: reg = -1

    if reg == -1:
        print "Error! Invalid register name in instruction '" + instruction.opcode + "' at " + instruction.parrent.fileName + "@" + str(instruction.parrent.lineNumber)
        sys.exit(1)
    else:
        return reg

def decodeComparison(instruction, comp):
    code = -1

    if   comp == "EQ"  : code = 0;
    elif comp == "NEQ" : code = 1;
    elif comp == "L"   : code = 2;
    elif comp == "LU"  : code = 3;
    elif comp == "GE"  : code = 4;
    elif comp == "GEU" : code = 5;
    else: code = -1

    if code == -1:
        print "Error! Invalid comparison name in instruction '" + instruction.opcode + "' at " + instruction.parrent.fileName + "@" + str(instruction.parrent.lineNumber)
        sys.exit(1)
    else:
        return code

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
            print "Error in instruction '" + instruction.opcode + "'  at " + instruction.parrent.fileName + "@" + str(instruction.parrent.lineNumber) + " immediate operand is supposed to be an symbol but contain non int value."
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
            print "Error in instruction '" + instruction.opcode + "'  at " + instruction.parrent.fileName + "@" + str(instruction.parrent.lineNumber) + " immediate operand is supposed to be an special symbol but contain non int value."
            sys.exit(1)


    #well... we don't know what key is => error
    print "Error! Immediate operand of '" + instruction.opcode + "'  at " + instruction.parrent.fileName + "@" + str(instruction.parrent.lineNumber) + " isn't number or symbol."
    sys.exit(1)

def checkSizeOfImmediate(instruction, bits_limit, value):
    if value > ((2**bits_limit)-1):
        print "Warning! Immediate operand of '" + instruction.opcode + "'  at " + instruction.parrent.fileName + "@" + str(instruction.parrent.lineNumber) + "is larger than allowed! It will be trimmed to right size!"
        return value & ((2**bits_limit)-1)
    else:
        return value
