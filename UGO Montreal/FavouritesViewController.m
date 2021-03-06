//
//  FavouritesViewController.m
//  UGO MTL
//
//  Created by Julien Saad on 2014-08-27.
//  Copyright (c) 2014 Développements Third Bridge Inc. All rights reserved.
//

#import "FavouritesViewController.h"
#import "TypeCell.h"
#import "Venue.h"
#import "AFNetworking.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ParallaxPhotoViewController.h"


@interface FavouritesViewController ()


@property Venue* nextVenue;
@property NSMutableArray* favourites;
@end

@implementation FavouritesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSString *)getUniqueDeviceIdentifierAsString
{
    
    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    
    NSString *strApplicationUUID = [SSKeychain passwordForService:appName account:@"incoding"];
    if (strApplicationUUID == nil)
    {
        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SSKeychain setPassword:strApplicationUUID forService:appName account:@"incoding"];
    }
    return strApplicationUUID;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setDataSourceDelegate:self];
    [self.tableView setTableViewDelegate:self];
    
    _favourites = [NSMutableArray array];
    
    // One array per type
    for(int i = 0; i<[self numberOfParentCells];i++){
        [_favourites addObject:[NSMutableArray array]];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = @{@"user_id": [self getUniqueDeviceIdentifierAsString]};

    
    [manager POST:[NSString stringWithFormat:@"%@/%@",REQUEST_URL, @"getFavouritesForUser"] parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              for(NSDictionary* t in responseObject){
                  //NSLog(@"%@", [d objectForKey:@"venue"]);
                  //`NSDictionary* t = [d objectForKey:@"venue"];
                  Venue* v = [[Venue alloc] init];
                  
                  
                  @try {
                      v.shortDesc = ISFRENCH?[t objectForKey:@"short_desc_fr"]:[t objectForKey:@"short_desc_en"];
                  }
                  @catch (NSException *exception) {
                      v.shortDesc = ISFRENCH?[t objectForKey:@"description_fr"]:[t objectForKey:@"description_en"];
                  }
                  @finally {
                      
                  }
                  
                  [v setBestTime:[t objectForKey:@"best_time"]];
                  [v setPriceText:[t objectForKey:@"price"]];
                  v.descriptionEn = ISFRENCH?[t objectForKey:@"description_fr"]:[t objectForKey:@"description_en"];
                  v.fbUrl = [t objectForKey:@"facebook_url"];
                  v.icono = [[t objectForKey:@"iconography"] intValue];
                  v.location = [t objectForKey:@"location"];
                  v.price = [[t objectForKey:@"price"] intValue];
                  v.type = [[t objectForKey:@"type"] intValue];
                  v.phoneNumber = [t objectForKey:@"phone"];
                  v.name = [t objectForKey:@"name"];
                  v.venueId = [t objectForKey:@"id"];
                  v.color = UIColorFromRGB([[t objectForKey:@"color"] intValue]);
                  v.imgUrls = [[NSMutableArray alloc] init];
                  for(NSDictionary* im in [t objectForKey:@"images"]){
                      [v.imgUrls addObject:[im objectForKey:@"url"]];
                  }
                  [_favourites[v.type] addObject:v];
                  v.personaId = [t objectForKey:@"persona_id"];
                  
                  
                 
                  
              }

              
              [_tableView reloadData];
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error %@", error);
          }];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Favourites Screen";
}

#pragma mark - SubTableDataSource - Parent

// @required
- (NSInteger)numberOfParentCells {
    
    return NUMBER_OF_TYPES;
}
- (NSInteger)heightForParentRows {
    
    return 175;
}

// @optional
- (NSString *)titleLabelForParentCellAtIndex:(NSInteger)parentIndex {
        
    switch (parentIndex) {
        case 0:
            return NSLocalizedString(@"EAT", nil);
            break;
        case 1:
            return NSLocalizedString(@"DRINK", nil);
            break;
        case 2:
            return NSLocalizedString(@"MOVE", nil);
            break;
        case 3:
            return NSLocalizedString(@"SHOP", nil);
            break;
        case 4:
            return NSLocalizedString(@"LEARN", nil);
            break;
            
        default:
            break;
    }
    return @"";
}
- (NSString *)subtitleLabelForParentCellAtIndex:(NSInteger)parentIndex {
    
    NSInteger childCount = [self numberOfChildCellsUnderParentIndex:parentIndex];
    if (childCount > 1)
        return [NSString stringWithFormat:ISFRENCH?@"%i endroits":@"%i places", (int)childCount];
    else if (childCount == 1)
        return [NSString stringWithFormat:ISFRENCH?@"%i endroit":@"%i place", (int)childCount];
    else
        return @"";//ISFRENCH?@"Aucun endroit":@"No places";
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [(ParallaxPhotoViewController*)segue.destinationViewController setVenue:_nextVenue];
}

#pragma mark - SubTableDataSource - Child

// @optional
- (void)tableView:(UITableView *)tableView didSelectCellAtChildIndex:(NSInteger)childIndex withInParentCellIndex:(NSInteger)parentIndex {
    
    _nextVenue = (Venue*)[[_favourites objectAtIndex:parentIndex] objectAtIndex:childIndex];
    
    [self performSegueWithIdentifier:@"DescriptionSegue" sender:self];
}


// @required
- (NSInteger)numberOfChildCellsUnderParentIndex:(NSInteger)parentIndex {
    
    return ((NSMutableArray*)_favourites[parentIndex]).count;
}
- (NSInteger)heightForChildRows {
    
    return 55;
}


// @optional
- (NSString *)titleLabelForCellAtChildIndex:(NSInteger)childIndex withinParentCellIndex:(NSInteger)parentIndex {
    if(_favourites.count!=0)
        return ((Venue*)_favourites[parentIndex][childIndex]).name;
    else
        return @"";
}
- (NSString *)subtitleLabelForCellAtChildIndex:(NSInteger)childIndex withinParentCellIndex:(NSInteger)parentIndex {
    
    return [NSString stringWithFormat:@"nested under parent %i",parentIndex + 1];
}

@end