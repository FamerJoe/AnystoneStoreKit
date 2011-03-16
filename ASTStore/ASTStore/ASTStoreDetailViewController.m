//
//  ASTStoreDetailViewController.m
//  ASTStore
//
//  Created by Sean Kormilo on 11-03-16.
//  Copyright 2011 Anystone Technologies, Inc. All rights reserved.
//

#import "ASTStoreDetailViewController.h"
#import "ASTStoreController.h"

@interface ASTStoreDetailViewController ()

@property (readonly) ASTStoreController *storeController;
@property (readonly) ASTStoreProduct *storeProduct;
@end

@implementation ASTStoreDetailViewController

@synthesize purchaseImage = purchaseImage_;
@synthesize productTitle = productTitle_;
@synthesize description = description_;
@synthesize extraInfo = extraInfo_;
@synthesize purchaseButton = purchaseButton_;
@synthesize storeController;
@synthesize storeProduct = storeProduct_;
@synthesize productIdentifier = productIdentifier_;
@synthesize onHand = onHand_;

- (ASTStoreController*)storeController
{
    return ( [ASTStoreController sharedStoreController] );
}

- (ASTStoreProduct*)storeProduct
{
    if( nil != storeProduct_ )
    {
        return storeProduct_;
    }
    
    storeProduct_ = [self.storeController storeProductForIdentifier:self.productIdentifier];
    [storeProduct_ retain];
    
    return ( storeProduct_ );
}


#pragma mark view updates
- (void)updateViewData
{
    // TODO: This should be customizable and associated with the product...
    self.purchaseImage.image = [UIImage imageNamed:@"default-purchase-image.png"];
    
    self.productTitle.text = [self.storeProduct localizedTitle];
    self.description.text = [self.storeProduct localizedDescription];
    self.extraInfo.text = self.storeProduct.extraInformation;
    
    NSString *purchaseTitle = nil;
    
    if( [self.storeController isProductPurchased:self.productIdentifier] )
    {
        purchaseTitle = @"Purchased - Thank You!";
                self.purchaseButton.enabled = NO;
    }
    else
    {
        purchaseTitle = [NSString stringWithFormat:@"Only %@", [self.storeProduct localizedPrice]];
        self.purchaseButton.enabled = YES;
    }
 
    [self.purchaseButton setTitle:purchaseTitle forState:UIControlStateNormal];
    [self.purchaseButton setTitle:purchaseTitle forState:UIControlStateHighlighted];
    
    if( self.storeProduct.type == ASTStoreProductIdentifierTypeConsumable )
    {
        self.onHand.text = [NSString stringWithFormat:@"On Hand: %d", 
                            [self.storeController availableQuantityForProduct:self.productIdentifier]];
    }
    else
    {
        self.onHand.text = nil;
    }
}


#pragma mark Actions

- (IBAction)purchaseButtonPressed:(id)sender 
{
    [self.storeController purchaseProduct:self.productIdentifier];
}

#pragma mark ASTStoreControllerDelegate Methods

- (void)astStoreControllerProductDataStateChanged:(ASTStoreControllerProductDataState)state
{
    DLog(@"stateChanged:%d", state);
    
    // Update table now that the state of the data has changed
    [self updateViewData];
}

- (void)astStoreControllerPurchaseStateChanged:(ASTStoreControllerPurchaseState)state
{
    DLog(@"purchaseStateChanged:%d", state);
    [self updateViewData];
}

// Should implement this, otherwise no purchase notifications for you
// Restore will invoke astStoreControllerProductIdentifierPurchased: for any restored purchases
- (void)astStoreControllerProductIdentifierPurchased:(NSString*)productIdentifier
{
    DLog(@"purchased: %@", productIdentifier);
    [self updateViewData];
}

#pragma mark Purchase Related Delegate Methods
// Invoked for actual purchase failures - may want to display a message to the user
- (void)astStoreControllerProductIdentifierFailedPurchase:(NSString*)productIdentifier withError:(NSError*)error
{
    DLog(@"failed purchase: %@ error:%@", productIdentifier, error);    
}

// Invoked for cancellations - no message should be shown to user per programming guide
- (void)astStoreControllerProductIdentifierCancelledPurchase:(NSString*)productIdentifier
{
    DLog(@"cancelled purchase: %@", productIdentifier);
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateViewData];
    self.storeController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.storeController.delegate = nil;
}

- (void)viewDidUnload
{
    [purchaseImage_ release];
    purchaseImage_ = nil;
    
    [productTitle_ release];
    productTitle_ = nil;
    
    [description_ release];
    description_ = nil;
    
    [extraInfo_ release];
    extraInfo_ = nil;
    
    [purchaseButton_ release];
    purchaseButton_ = nil;
    
    [onHand_ release];
    onHand_ = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [purchaseImage_ release];
    [productTitle_ release];
    [description_ release];
    [extraInfo_ release];
    [purchaseButton_ release];
    
    [productIdentifier_ release];
    productIdentifier_ = nil;
    
    [onHand_ release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}


@end