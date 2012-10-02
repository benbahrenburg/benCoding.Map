/**
 * benCoding.Map
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BBGeoJSONParser.h"

@implementation BBGeoJSONParser
@synthesize Code,Name,Polygons;

- (id) initWithFilePath:(NSString*)filePath
{
    jsonFilePath=filePath;
}

-(void)dealloc
{
    if(Polygons!=nil)
    {
        RELEASE_TO_NIL(Polygons);
    }
    if(Name!=nil)
    {
        RELEASE_TO_NIL(Name);
    }
    if(Code!=nil)
    {
        RELEASE_TO_NIL(Code);
    }
	[super dealloc];
}

-(void)addPoint:(NSMutableArray*)points
{
    NSUInteger pointsCount = [points count];
    if(pointsCount==0)
    {
        return;
    }
    
    //Create the number of points provided
    CLLocationCoordinate2D  pointsToAdd[pointsCount];
    
    for (int iLoop = 0; iLoop < pointsCount; iLoop++)
    {
        pointsToAdd[iLoop]= CLLocationCoordinate2DMake([[points objectAtIndex:iLoop] coordinate].latitude,
                                                       [[points objectAtIndex:iLoop] coordinate].longitude);
    }
    
    MKPolygon* polygonToAdd = [[MKPolygon polygonWithCoordinates:pointsToAdd count:pointsCount] autorelease];
    NSLog(@"Adding polygon with points %u",[points count]);
    [Polygons addObject:polygonToAdd];
}

-(BOOL)hasNoChild:(NSArray*)coord
{
    
    NSString * coordType = NSStringFromClass ([coord class]);
    
    if ([coordType rangeOfString:@"array" options:NSCaseInsensitiveSearch].location == NSNotFound)
    {
        return YES;
    }
    
    NSString *childCheck = NSStringFromClass ([[coord objectAtIndex:0] class]);
    
    if ([childCheck rangeOfString:@"array" options:NSCaseInsensitiveSearch].location == NSNotFound)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

-(void)parseCoords:(NSArray*)coordinates
{
    NSUInteger nodeCount = [coordinates count];
    NSMutableArray *points =[[[NSMutableArray alloc] init] autorelease];
    
    for (int iLoop = 0; iLoop < nodeCount; iLoop++)
    {
        if([self hasNoChild:[coordinates objectAtIndex:iLoop]]==YES)
        {
            CLLocation *point = [[[CLLocation alloc] initWithLatitude:[[[coordinates objectAtIndex:iLoop] objectAtIndex:0] doubleValue]
                                                            longitude:[[[coordinates objectAtIndex:iLoop] objectAtIndex:1]doubleValue]] autorelease];
            [points addObject:point];
            
        }
        else
        {
            [self parseCoords:[coordinates objectAtIndex:iLoop]];
        }
    }
    if([points count]>0)
    {
        [self addPoint:points];
    }
    
}

-(NSString*) findName:(NSDictionary*)json
{
    NSDictionary * properties = [json objectForKey:@"properties"];
    NSString * name = [properties objectForKey:@"name"];
    return name;
}
-(NSString*) findCode:(NSDictionary*)json
{
    NSString * code = [json objectForKey:@"id"];
    return code;
}
-(BOOL) validRoot:(NSArray *) root
{
    if(root == nil)
    {
        return NO;
    }
    if([root count]==0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
-(void) Parse
{
    if(Polygons!=nil)
    {
        RELEASE_TO_NIL(Polygons);
    }

    if(Name!=nil)
    {
        RELEASE_TO_NIL(Name);
    }
    if(Code!=nil)
    {
        RELEASE_TO_NIL(Code);
    }
    
    NSData* jsonData = [NSData dataWithContentsOfFile: jsonFilePath];
    JSONDecoder* decoder = [[[JSONDecoder alloc]
                             initWithParseOptions:JKParseOptionLooseUnicode] autorelease];
    NSDictionary* json = [decoder objectWithData:jsonData];
    
    if(json==nil)
    {
        NSLog(@"Invalid JSON format, unable to continue");
        return;
    }
    NSArray * root = [json objectForKey:@"features"];
    if([self validRoot:root]==NO)
    {
        NSLog(@"Invalid Geo JSON provided, unable to continue");
        return;
    }
    
    //Parse the Name and Code Properties
    Code = [self findName:[root objectAtIndex:0]];
    Name = [self findCode:[root objectAtIndex:0]];
    //Find the Coordinates Node
    NSArray * coordinates = [[[root objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"coordinates"];
    //Parse the coordinates into polygons
    [self parseCoords:coordinates];
}


@end
