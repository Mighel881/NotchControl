#import "./headers/MarqueeLabel.h"
#import "./headers/MediaRemote.h"
#import "./headers/UIImage+tintColor.h"
#import "./headers/UIImage+ScaledImage.h"

UIView *gestureView;
UIView *notchView;
UIScrollView *scrollView;

//Music Preview View
UIView *musicPreviewView;
UIImageView *artWorkView;
MarqueeLabel *musicTitleLabel;
MarqueeLabel *musicArtistLabel;

//Muisc Control View
UIView *musicControlView;
UIImageView *musicBackView;
UIImageView *musicPlayView;
UIImageView *musicNextView;

//Essenstials
UIView *clockView;
UILabel *clockLabel;

__attribute__((unused)) static UIImage* UIKitImage(NSString* imgName)
{
    NSString* artworkPath = @"/System/Library/PrivateFrameworks/UIKitCore.framework/Artwork.bundle";
    NSBundle* artworkBundle = [NSBundle bundleWithPath:artworkPath];
    if (!artworkBundle)
    {
        artworkPath = @"/System/Library/Frameworks/UIKit.framework/Artwork.bundle";
        artworkBundle = [NSBundle bundleWithPath:artworkPath];
    }
    UIImage* barsImg = [UIImage imageNamed:imgName inBundle:artworkBundle compatibleWithTraitCollection:nil];
	barsImg = [barsImg imageWithTintedColor:[UIColor whiteColor]];
	barsImg = [barsImg scaleImageToSize:CGSizeMake(20, 20)];

    return barsImg;
}

%hook UIWindow
-(void)layoutSubviews {
	%orig;

	if (!gestureView) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo) name:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateButton) name:(__bridge NSString*)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];

		gestureView = [[UIView alloc] initWithFrame:CGRectMake(83, -30, 209, 65)]; //Size for iPX, IPXS
		gestureView.backgroundColor = [UIColor clearColor];
		gestureView.clipsToBounds = YES;
		gestureView.layer.cornerRadius = 23;
		[self addSubview:gestureView];

		UISwipeGestureRecognizer *downGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedNotch:)];
    	downGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    	downGestureRecognizer.numberOfTouchesRequired = 1;
    	[gestureView addGestureRecognizer:downGestureRecognizer];

		notchView = [[UIView alloc] initWithFrame:CGRectMake(83, -120, 209, 120)]; //Size for iPX, IPXS
		notchView.backgroundColor = [UIColor blackColor];
		notchView.clipsToBounds = YES;
		notchView.layer.cornerRadius = 23;
		[self addSubview:notchView];

		UISwipeGestureRecognizer *upGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedUpNotch:)];
    	upGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    	upGestureRecognizer.numberOfTouchesRequired = 1;
    	[notchView addGestureRecognizer:upGestureRecognizer];

		scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, notchView.frame.size.width, 60)];
		scrollView.backgroundColor = [UIColor blackColor];
		scrollView.pagingEnabled = YES;
		[notchView addSubview:scrollView];

		[scrollView setContentSize:CGSizeMake(notchView.frame.size.width * 3, 60)];

		//Music Preview View Start
		musicPreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
		musicPreviewView.backgroundColor = [UIColor blackColor];
		[scrollView addSubview:musicPreviewView];

		artWorkView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 5, 50, 50)];
		artWorkView.backgroundColor = [UIColor greenColor];
		artWorkView.clipsToBounds = YES;
		artWorkView.layer.cornerRadius = 15;
		[musicPreviewView addSubview:artWorkView];

		musicTitleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(60, 10, 140, 15) duration:8.0 andFadeLength:10.0f];
		musicTitleLabel.font = [UIFont fontWithName:@".SFUIText-Bold" size:15];
		musicTitleLabel.textColor = [UIColor whiteColor];
		[musicPreviewView addSubview:musicTitleLabel];

		musicArtistLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(60, 30, 140, 15) duration:8.0 andFadeLength:10.0f];
		musicArtistLabel.font = [UIFont fontWithName:@".SFUIText" size:15];
		musicArtistLabel.textColor = [UIColor whiteColor];
		[musicPreviewView addSubview:musicArtistLabel];
		//Music Preview View End

		//Music Control Start
		musicControlView = [[UIView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
		musicControlView.backgroundColor = [UIColor blackColor];
		[scrollView addSubview:musicControlView];

		musicBackView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 20, 20, 20)];
		musicBackView.backgroundColor = [UIColor clearColor];
		musicBackView.image = UIKitImage(@"UIButtonBarRewind");
		musicBackView.userInteractionEnabled = YES;
		[musicControlView addSubview:musicBackView];
		UITapGestureRecognizer *musicBackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(musicBackTap:)];
		musicBackTap.numberOfTapsRequired = 1;
		[musicBackView addGestureRecognizer:musicBackTap];

		musicPlayView = [[UIImageView alloc] initWithFrame:CGRectMake(94.5, 20, 20, 20)];
		musicPlayView.backgroundColor = [UIColor clearColor];
		musicPlayView.userInteractionEnabled = YES;
		[musicControlView addSubview:musicPlayView];
		UITapGestureRecognizer *musicPlayTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(musicPlayTap:)];
		musicPlayTap.numberOfTapsRequired = 1;
		[musicPlayView addGestureRecognizer:musicPlayTap];

		musicNextView = [[UIImageView alloc] initWithFrame:CGRectMake(174, 20, 20, 20)];
		musicNextView.backgroundColor = [UIColor clearColor];
		musicNextView.image = UIKitImage(@"UIButtonBarFastForward");
		musicNextView.userInteractionEnabled = YES;
		[musicControlView addSubview:musicNextView];
		UITapGestureRecognizer *musicNextTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(musicNextTap:)];
		musicNextTap.numberOfTapsRequired = 1;
		[musicNextView addGestureRecognizer:musicNextTap];
		//Music Control End

		//Essenstials Start
		clockView = [[UIView alloc] initWithFrame:CGRectMake(scrollView.frame.size.width * 2, 0, scrollView.frame.size.width, scrollView.frame.size.height)];
		clockView.backgroundColor = [UIColor blackColor];
		[scrollView addSubview:clockView];

		NSDate *curDate = [NSDate date];
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
		[dateFormatter setDateFormat:@"HH:mm"];
		NSString *dateString = [dateFormatter stringFromDate:curDate];

		clockLabel = [[UILabel alloc] initWithFrame:CGRectMake(54.5, 15, 100, 30)];
		clockLabel.font = [UIFont fontWithName:@".SFUIText" size:30];
		clockLabel.text = dateString;
		clockLabel.textColor = [UIColor whiteColor];
		clockLabel.textAlignment = NSTextAlignmentCenter;
		[clockView addSubview:clockLabel];
		//Essenstials End
	}
}

%new
-(void)swipedNotch:(UISwipeGestureRecognizer *)gesture {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	notchView.frame = CGRectMake(83, -30, 209, 120);
	[UIView commitAnimations];
}

%new
-(void)swipedUpNotch:(UISwipeGestureRecognizer *)gesture {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	notchView.frame = CGRectMake(83, -120, 209, 120);
	[UIView commitAnimations];
}

%new
-(void)musicBackTap:(UITapGestureRecognizer *)gesture {
	MRMediaRemoteSendCommand(kMRPreviousTrack, nil);
}

%new
-(void)musicPlayTap:(UITapGestureRecognizer *)gesture {
	MRMediaRemoteSendCommand(kMRTogglePlayPause, nil);
}

%new
-(void)musicNextTap:(UITapGestureRecognizer *)gesture {
	MRMediaRemoteSendCommand(kMRNextTrack, nil);
}

%new
-(void)updateInfo {
	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary *dict=(__bridge NSDictionary *)(information);
		if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData] != nil) {
			NSData *artworkData = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
			artWorkView.image = [UIImage imageWithData:artworkData];
		}
	});

	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary *dict=(__bridge NSDictionary *)(information);
		if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData] != nil) {
			musicTitleLabel.text = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
		}
	});

	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) {
        NSDictionary *dict=(__bridge NSDictionary *)(information);
		if ([dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData] != nil) {
			musicArtistLabel.text = [dict objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
		}
	});
}

%new
-(void)updateButton {
	MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlaying) {
        if (isPlaying) {
            //playing
			musicPlayView.image = UIKitImage(@"UIButtonBarPause");
        } else {
            //paused
            musicPlayView.image = UIKitImage(@"UIButtonBarPlay");
        }
    });
}

%new
-(void)updateTime {
	NSDate *curDate = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
	[dateFormatter setDateFormat:@"hh:mm"];
	NSString *dateString = [dateFormatter stringFromDate:curDate];
	
	clockLabel.text = dateString;
}
%end