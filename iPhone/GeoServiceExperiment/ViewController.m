//
//  ViewController.m
//  GeoServiceExperiment
//
//  Created by Dmitry Manayev on 30.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ViewController.h"

static const int ddLogLevel = LOG_LEVEL_INFO;

#ifndef NSDateTimeAgoLocalizedStrings
#define NSDateTimeAgoLocalizedStrings(key) \
NSLocalizedStringFromTable(key, @"NSDateTimeAgo", nil)
#endif

#define HOST @"please add port"
#define PORT 1111


#define BEAT_MESSAGE 123456789
#define ERROR_MESSAGE 987654321


@interface ViewController ()
{
    CLLocationManager *_locationManager;
    CLLocation *_userLocation;
    NSTimer *_beatTimer;
    NSTimer *_positionTimer;
    BOOL startedPosition;
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
@synthesize logsTextView;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _beatTimer = [[NSTimer alloc] init];
    _positionTimer = [[NSTimer alloc] init];
    endButton.enabled = NO;
    timeInterval =(int)(timePeriodSlider.value + 0.5f);
    self.timePeriodLabel.text = [self timeFormat:timeInterval];
    requestCountLabel.text = [[NSNumber numberWithInt:requestCount] stringValue];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [_locationManager startUpdatingLocation];
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err = nil;
    if (![asyncSocket connectToHost:HOST onPort:PORT error:&err]) {
        [self textViewLog:[NSString stringWithFormat: @"Can't connect to host %@ on port %d",HOST,PORT]];
    }
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
    _beatTimer = nil;
    _positionTimer = nil;
    [self setStartButton:nil];
    [self setEndButton:nil];
    [self setStartTimeLabel:nil];
    [self setEndTimeLabel:nil];
    [self setLogsTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}  


#pragma mark - private methods
              
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

-(NSString *)getFormattedLongitude
{
    double longitude = _userLocation.coordinate.longitude*100;
    if (longitude < 0) {
        return [NSString stringWithFormat:@"E%0.4f",(-1)*longitude];
    }
    return [NSString stringWithFormat:@"W%0.4f",longitude];
}

-(NSString *)getFormattedLatitude
{
    double latitude = _userLocation.coordinate.latitude * 100;
    if (latitude < 0) {
        return [NSString stringWithFormat:@"S%0.4f",(-1)*latitude];
    }
    return [NSString stringWithFormat:@"N%0.4f",latitude];
}

-(NSString *)getUTCFormateDate:(NSString *) formate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:formate];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    return dateString;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// It's almost like NSLog, but directed to a UITextView control.
//
// usage example:  [self textViewLog:@"%@", myVar];
//
- (void)textViewLog:(NSString *)message
{
    NSString *log_msg = [NSString stringWithFormat:@"%@: %@",[self timeNow],message];
    
    self.logsTextView.text = [NSString stringWithFormat:@"%@ %@\n", self.logsTextView.text, log_msg];
    
    // Support auto-scroll.
    NSRange range = NSMakeRange(self.logsTextView.text.length - 1, 1);
    [self.logsTextView scrollRangeToVisible:range];
}

#pragma mark - Socket

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    DDLogInfo(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    [self textViewLog:[NSString stringWithFormat: @"Connected to host %@ on port %d",host,port]];
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    DDLogInfo(@"socket:%p didReadData:withTag:%ld", sock, tag);
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self textViewLog:response];
//    NSRange rangeOfDash = [response rangeOfString:@"GOLFINFO"];
//    if (rangeOfDash.location != NSNotFound) {
//        [self sendErrorMessage];
    if (!startedPosition) {
        _positionTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(sendPositionMessage) userInfo:nil repeats:YES];
        startedPosition = YES;
    }
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    DDLogInfo(@"socketDidDisconnect:%p withError: %@", sock, err);
    [self textViewLog:[NSString stringWithFormat: @"Disconnected"]];
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
//    DDLogInfo(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

#pragma mark - Actions

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
    [_beatTimer invalidate];
    [_positionTimer invalidate];
    
    startTimeLabel.text = [self timeNow];
    endTimeLabel.text = nil;
    
    if ([asyncSocket isDisconnected]) {
        if (![asyncSocket connectToHost:HOST onPort:PORT error:nil]) {
            [self textViewLog:[NSString stringWithFormat: @"Can't connect to host %@ on port %d",HOST,PORT]];
        }
    }
    
    [self sendBeatMessage];
    _beatTimer = [NSTimer scheduledTimerWithTimeInterval:30*60 target:self selector:@selector(sendBeatMessage) userInfo:nil repeats:YES];
}

- (IBAction)endButtonClick:(id)sender {
    [_beatTimer invalidate];
    [_positionTimer invalidate];
    endButton.enabled = NO;
    startButton.enabled = YES;
    timePeriodSlider.enabled = YES;
    
    startedPosition = NO;
    endTimeLabel.text = [self timeNow];
    logsTextView.text = nil;
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
    
#pragma mark - Socket Messages

-(void) sendBeatMessage {
    requestCount += 1;
    requestCountLabel.text = [[NSNumber numberWithInt:requestCount] stringValue];
    
    NSData *data = [@"beat" dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData: data withTimeout:-1 tag:BEAT_MESSAGE];
    [asyncSocket readDataWithTimeout:10 tag:BEAT_MESSAGE];
}

-(void)sendPositionMessage
{
    requestCount += 1;
    requestCountLabel.text = [[NSNumber numberWithInt:requestCount] stringValue];
    
    NSMutableString *message = [[NSMutableString alloc] initWithString:@"ideal"];
    //add altitude
    [message appendFormat:@"%04.1f,",_userLocation.altitude];
    //add latitude
    [message appendFormat:@"%@,",[self getFormattedLatitude]];
    //add longitude
    [message appendFormat:@"%@,",[self getFormattedLongitude]];
    //add speed
    [message appendFormat:@"%0.1f,",_userLocation.speed];
    //add direction
    [message appendFormat:@"%0.1f,",_userLocation.course];
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
//    DDLogInfo(message);
    
    [asyncSocket writeData: data withTimeout:-1 tag:requestCount];
    //[asyncSocket readDataWithTimeout:10 tag:requestCount];
}

-(void)sendErrorMessage
{
    requestCount += 1;
    requestCountLabel.text = [[NSNumber numberWithInt:requestCount] stringValue];
    
    NSData *data = [@"EROROR#" dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData: data withTimeout:-1 tag:ERROR_MESSAGE];
    [asyncSocket readDataWithTimeout:30 tag:ERROR_MESSAGE];
}
    
@end
