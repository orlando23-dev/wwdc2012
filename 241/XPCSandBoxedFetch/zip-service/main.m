//
//  main.m
//  zip-service
//
//  Created by Ding Orlando on 11/24/12.
//  Copyright (c) 2012 Ding Orlando. All rights reserved.
//

#include <xpc/xpc.h>
#include <Foundation/Foundation.h>
#include "Zipper.h"

int main(int argc, const char *argv[])
{
    NSXPCListener *serviceListener = [NSXPCListener serviceListener];
    Zipper *serviceDelegate = [Zipper sharedZipper];
    serviceListener.delegate = serviceDelegate;
    [serviceListener resume];
	return 0;
}
