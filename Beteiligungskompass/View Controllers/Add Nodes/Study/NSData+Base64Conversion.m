//
//  NSData+Base64Conversion.m
//  Beteiligungskompass
//
//  Copyright (C) 2013 Bertelsmann Stiftung
//

#import "NSData+Base64Conversion.h"


@implementation NSData (Base64Conversion)
-(NSString *) EncodeUsingBase64
{
	char table[]={'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
		'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
		'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
	'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/'};
	
	int length=[self length];
	UInt8 *data=(UInt8*)[self bytes];
	
	int nBytes=0;
	int buffer=0;
	UInt8 *walk=data;
	NSMutableString *string=[[NSMutableString alloc] init];
	for(int i=0;i<length;i++)
	{
		buffer=buffer<<8;
		buffer=buffer|*walk;
		nBytes++;
		walk++;
		if(nBytes==3)
		{
			char c=table[buffer>>18];
			[string appendFormat:@"%c",c];
			c=table[(buffer>>12)&0x3F];
			[string appendFormat:@"%c",c];
			c=table[(buffer>>6)&0x3F];
			[string appendFormat:@"%c",c];
			c=table[(buffer)&0x3F];
			[string appendFormat:@"%c",c];
			nBytes=0;
			buffer=0;
		}
	}
	for(int i=nBytes;i<3;i++)
		buffer=buffer<<8;
	if(nBytes>0)
	{
		char c=table[buffer>>18];
		[string appendFormat:@"%c",c];
		c=table[(buffer>>12)&0x3F];
		[string appendFormat:@"%c",c];
		if(nBytes>1)
		{
			c=table[(buffer>>6)&0x3F];
			[string appendFormat:@"%c=",c];
		}
		else
		{
			[string appendString:@"=="];
		}
	}
	return string;
}

+(NSData *) dataFromBase64:(NSString*) data
{
	unsigned char table[256];
	//Table setup
	{
		table['A']=0;
		table['B']=1;
		table['C']=2;
		table['D']=3;
		table['E']=4;
		table['F']=5;
		table['G']=6;
		table['H']=7;
		table['I']=8;
		table['J']=9;
		table['K']=10;
		table['L']=11;
		table['M']=12;
		table['N']=13;
		table['O']=14;
		table['P']=15;
		table['Q']=16;
		table['R']=17;
		table['S']=18;
		table['T']=19;
		table['U']=20;
		table['V']=21;
		table['W']=22;
		table['X']=23;
		table['Y']=24;
		table['Z']=25;
		table['a']=26;
		table['b']=27;
		table['c']=28;
		table['d']=29;
		table['e']=30;
		table['f']=31;
		table['g']=32;
		table['h']=33;
		table['i']=34;
		table['j']=35;
		table['k']=36;
		table['l']=37;
		table['m']=38;
		table['n']=39;
		table['o']=40;
		table['p']=41;
		table['q']=42;
		table['r']=43;
		table['s']=44;
		table['t']=45;
		table['u']=46;
		table['v']=47;
		table['w']=48;
		table['x']=49;
		table['y']=50;
		table['z']=51;
		table['0']=52;
		table['1']=53;
		table['2']=54;
		table['3']=55;
		table['4']=56;
		table['5']=57;
		table['6']=58;
		table['7']=59;
		table['8']=60;
		table['9']=61;
		table['+']=62;
		table['/']=63;
		table['=']=0;
	}
	
	NSCharacterSet *set=[NSCharacterSet characterSetWithCharactersInString:@"="];
	NSRange range=[data rangeOfCharacterFromSet:set];
	int subtract=0;
	if(range.location!=NSNotFound)
	{
		subtract=[data length] - range.location;
	}
	UInt8 *buf=malloc(([data length]*3)/4-subtract);
	UInt8 *walk=buf;
	int nChars=0;
	unichar tempbuf[4];
	for(int i=0;i<[data length];i++)
	{
		unichar c=[data characterAtIndex:i];
		if(c!=' ')
		{
			tempbuf[nChars]=c;
			nChars++;
		}
		if(nChars==4)
		{
			nChars=0;
			int temp=table[tempbuf[0]];
			temp=temp<<6;
			temp=temp|table[tempbuf[1]];
			temp=temp<<6;
			temp=temp|table[tempbuf[2]];
			temp=temp<<6;
			temp=temp|table[tempbuf[3]];
			
			*walk=temp>>16;
			walk++;
			if(tempbuf[2]!='=')
			{
				*walk=(temp>>8)&0xFF;
				walk++;
			}
			if(tempbuf[3]!='=')
			{
				*walk=(temp)&0xFF;
				walk++;
			}
		}
	}
	NSData *decodeddata=[[NSData alloc] initWithBytes:buf length:walk-buf];
	free(buf);
	return decodeddata;
}

-(NSString *) EncodeUsingHex
{
    unsigned char *buf=(unsigned char*)[self bytes];
    NSMutableString *str=[NSMutableString stringWithCapacity:[self length]*2];
    for(int i=0;i<[self length];i++)
    {
        unsigned char val=*buf;
        [str appendFormat:@"%02x",(int)val];
        buf++;
    }
    return str;
}

@end
