//
//  ViewController.m
//  GeoServiceExperiment
//
//  Created by Dmitry Manayev on 30.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#ifndef NSDateTimeAgoLocalizedStrings
#define NSDateTimeAgoLocalizedStrings(key) \
NSLocalizedStringFromTable(key, @"NSDateTimeAgo", nil)
#endif

#define URL @"https://api.vk.com/method/friends.get?fields=first_name,last_name"
//Put here access token or this will not work
#define ACCESS_TOKEN @""

@interface ViewController ()
{
    CLLocationManager *_locationManager;
    CLLocation *_userLocation;
    NSTimer *_timer;
    int timeInterval;
    int requestCount;
}
@end

@implementation ViewController
@synthesize timePeriodSlider;
@synthesize timePeriodLabel;
@synthesize requestCountLabel;
@synthesize latitudeLabel;
@synthesize longitudeLabel;
@synthesize startButton;
@synthesize endButton;
@synthesize startTimeLabel;
@synthesize endTimeLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _timer = [[NSTimer alloc] init];
    endButton.enabled = NO;
    timeInterval =(int)(timePeriodSlider.value + 0.5f);
    self.timePeriodLabel.text = [self timeFormat:timeInterval];
    requestCountLabel.text = [[NSNumber numberWithInt:requestCount] stringValue];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [_locationManager startUpdatingLocation];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setTimePeriodSlider:nil];
    [self setTimePeriodLabel:nil];
    [self setRequestCountLabel:nil];
    [self setLatitudeLabel:nil];
    [self setLongitudeLabel:nil];
    _locationManager = nil;
    _timer = nil;
    [self setStartButton:nil];
    [self setEndButton:nil];
    [self setStartTimeLabel:nil];
    [self setEndTimeLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}  

- (IBAction)timePeriodChanged:(id)sender {
    UISlider *slider = (UISlider *) sender;
    timeInterval =(int)(slider.value + 0.5f);
    self.timePeriodLabel.text = [self timeFormat:timeInterval];
}

- (IBAction)startButtonClick:(id)sender {
    endButton.enabled = YES;
    startButton.enabled = NO;
    timePeriodSlider.enabled = NO;
    requestCount = 0;
    requestCountLabel.text = [[NSNumber numberWithInt:requestCount] stringValue];
    [_timer invalidate];
    
    startTimeLabel.text = [self timeNow];
    endTimeLabel.text = nil;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(sendRequest) userInfo:nil repeats:YES];
}

- (IBAction)endButtonClick:(id)sender {
    [_timer invalidate];
    endButton.enabled = NO;
    startButton.enabled = YES;
    timePeriodSlider.enabled = YES;
    
    endTimeLabel.text = [self timeNow];
}
              
-(void) sendRequest {
    requestCount += 1;
    requestCountLabel.text = [[NSNumber numberWithInt:requestCount] stringValue];
    
    NSString *query = [NSString stringWithFormat:@"%@&access_token=%@", URL, ACCESS_TOKEN];
    query = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // NSLog(@"[%@ %@] sent %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), query);
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:query] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
    
//    NSURLRequest *request = [[NSURLRequest requestWithURL:url] retain];
//    NSURLResponse *response = nil;
//    NSError* error = nil;
//    receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message: error.description
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(NSString *)timeFormat:(int) seconds {
    
    int minutes = seconds/60;
    int secondsLeft = round(seconds - 60 * minutes);
    
    if(seconds < 60) {
        return [NSString stringWithFormat: NSDateTimeAgoLocalizedStrings(@"%d sec"), seconds];
    } else {
        return [NSString stringWithFormat: NSDateTimeAgoLocalizedStrings(@"%d min %d sec"), minutes, secondsLeft];
    }
}

-(NSString *)timeNow
{
    NSDate *today = [NSDate date];
    NSDateFormatter * date_format = [[NSDateFormatter alloc] init];
    [date_format setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    return [date_format stringFromDate: today];
}

#pragma mark - Location Manager

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
//    [POAppDelegate appDelegate].userLocation  = newLocation;
    _userLocation = newLocation;//[[CLLocation alloc] initWithLatitude:60.07 longitude:30.19];
    self.latitudeLabel.text = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorType = (error.code == kCLErrorDenied) ? @"Access Denied" : @"Unknown Error";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting Location"
                                                    message:errorType
                                                   delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}


@end
