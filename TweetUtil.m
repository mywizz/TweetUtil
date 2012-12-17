// TweetUtil.m
//
// Copyright (c) 2012 Yunseok Kim (http://mywizz.me/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

static NSInteger kTweetUtilShortURLLength = 20;
NSUInteger const kTweetUtilMaxCharactersCount = 140;


#import "TweetUtil.h"
#import "NSString+URLDetect.h"


@implementation TweetUtil

// ---------------------------------------------------------------------
#pragma mark -
#pragma mark Characters counting

+ (BOOL)isExceedingMaxCharactersCount:(NSString *)body
{
	return [self charactersCount:body] > kTweetUtilMaxCharactersCount;
}

+ (NSUInteger)charactersCount:(NSString *)body
{
	body = [self normalizeTweet:body];
	if ([body containsURLIncludingSchemeless])
	{
		NSArray *urls = [body componentsByDetectedURLsIncludingSchemeless];
		
		NSString *dummyString = [@"" stringByPaddingToLength:kTweetUtilShortURLLength withString: @"a" startingAtIndex:0];
		NSString *dummySecureString = [@"" stringByPaddingToLength:kTweetUtilShortURLLength + 1 withString: @"a" startingAtIndex:0];
		for (NSURL *url in urls)
		{
			NSString *urlString = url.absoluteString;
			NSRange range = [body rangeOfString:urlString];
			if (range.location == NSNotFound)
			{
				NSString *protocolessURL = [[urlString stringByReplacingOccurrencesOfString:@"http://" withString:@""] stringByReplacingOccurrencesOfString:@"https" withString:@""];
				body = [body stringByReplacingOccurrencesOfString:protocolessURL withString:dummyString];
			}
			else
			{
				body = [body stringByReplacingOccurrencesOfString:urlString withString:([url.scheme isEqualToString:@"https"] ? dummySecureString : dummyString)];
			}
		}
	}
	
	return [body length];
}

+ (NSString *)normalizeTweet:(NSString *)body
{
	return [body stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

// ---------------------------------------------------------------------
#pragma mark -
#pragma mark Spliting tweet

+ (NSArray *)splitIntoMultipleTweets:(NSString *)body
{
	body = [self normalizeTweet:body];
	
	if ([self charactersCount:body] <= kTweetUtilMaxCharactersCount)
	{
		return [NSArray arrayWithObject:body];
	}
	
	NSMutableArray *tweets = [NSMutableArray new];
	NSMutableArray *frags = [[body componentsSeparatedByString:@" "] mutableCopy];
	NSMutableString *tweet = [NSMutableString new];
	
	while ([frags count] > 0)
	{
		NSString *frag = [frags objectAtIndex:0];
		
		[frags removeObjectAtIndex:0];
		
		if ([tweet length] <= kTweetUtilMaxCharactersCount - [frag length] - 1)
		{
			[tweet appendFormat:@" %@", frag];
		}
		else
		{
			[tweets addObject:tweet];
			tweet = [NSMutableString stringWithString:frag];
		}
	}
	
	if (tweet)
	{
		[tweets addObject:tweet];
	}
	
	return tweets;
}

@end