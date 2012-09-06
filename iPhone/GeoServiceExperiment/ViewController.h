//
//  ViewController.h
//  GeoServiceExperiment
//
//  Created by Dmitry Manayev on 30.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GCDAsyncSocket.h"
#import "DDLog.h"

@interface ViewController : UIViewController<CLLocationManagerDelegate, GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *asyncSocket;
}

@property (weak, nonatomic) IBOutlet UISlider *timePeriodSlider;
@property (weak, nonatomic) IBOutlet UILabel *timePeriodLabel;
@property (weak, nonatomic) IBOutlet UILabel *requestCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *endButton;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UITextView *logsTextView;

- (IBAction)timePeriodChanged:(id)sender;
- (IBAction)startButtonClick:(id)sender;
- (IBAction)endButtonClick:(id)sender;
@end
