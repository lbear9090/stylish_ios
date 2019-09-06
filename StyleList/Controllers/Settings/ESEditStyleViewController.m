//
//  ESEditStyleViewController.m


#import "ESEditStyleViewController.h"
#import "ESStyleTableViewCell.h"
#import "ESMyStyleViewController.h"
#import "MBProgressHUD.h"
@interface ESEditStyleViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *mSelected;
    int selectedNumber;
    NSMutableArray *selectedNameAry;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextView *txtViewStyleGuide;
@property (nonatomic, strong) PFObject *sensitiveData;
@property (strong, nonatomic) NSMutableArray *arr_SelectedCategoryName;
@property (strong, nonatomic) NSMutableArray *arr_SelectedCategoryBool;
@property (assign)            BOOL           selectPossibleCategory;

@end

@implementation ESEditStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selectedNumber = 0;
    id barButtonAppearance = [UIBarButtonItem appearance];
    NSDictionary *barButtonTextAttributes = @{
                                              UITextAttributeFont: [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:15.0f],
                                              UITextAttributeTextShadowColor: [UIColor blackColor],
                                              UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]
                                              };
    
    [barButtonAppearance setTitleTextAttributes:barButtonTextAttributes
                                       forState:UIControlStateNormal];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName:[UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:21]}];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.selectPossibleCategory = NO;
    ESCache *shared = [ESCache sharedCache];
    PFUser *currentUser = [PFUser currentUser];
    NSString *currentUserId = [currentUser valueForKey:@"objectId"];
    //=========== if select image of choosephoto or cameraphoto and logined userId=========//
    if ([shared.selectedUserId isEqualToString:currentUserId]) {
        [self secondNavigationBarShow];
        self.selectPossibleCategory = YES;
    }else{
        [self secondNavigationBarShow];
        self.selectPossibleCategory = NO;
    }
    if ([shared.selectedBtnTag isEqualToString:@"TakePhoto"] || [shared.selectedBtnTag isEqualToString:@"ChoosePhoto"]){
        [self firstNavigationBarShow];
        [self showStyleGuide];
        self.selectPossibleCategory = YES;
        NSString *strGender = [NSString stringWithFormat:@"%@",[currentUser objectForKey:@"Gender"]];
        shared.selectedUserGender = strGender;
    }
    if ([shared.selectedBtnTag isEqualToString:@"EditStyleBtnTag"]) {
        [self secondNavigationBarShow];
        self.selectPossibleCategory = YES;
        NSString *strGender = [NSString stringWithFormat:@"%@",[currentUser objectForKey:@"Gender"]];
        shared.selectedUserGender = strGender;
    }
    //=====================================================================================//
    //===================== init category name array ======================================//
    self.arr_SelectedCategoryName = [[NSMutableArray alloc]init];
    self.arr_SelectedCategoryBool = [[NSMutableArray alloc]init];
    selectedNameAry = [[NSMutableArray alloc]init];
    
    if ([shared.selectedUserGender isEqualToString:@""] || shared.selectedUserGender == nil || [shared.selectedUserGender isEqualToString:@"(null)"]) {
        self.arr_SelectedCategoryName = [self getSelectedCategoryNameArray:MALE];
    }else if ([shared.selectedUserGender isEqualToString:MALE]){
        self.arr_SelectedCategoryName = [self getSelectedCategoryNameArray:MALE];
    }else if ([shared.selectedUserGender isEqualToString:FEMALE]){
        self.arr_SelectedCategoryName = [self getSelectedCategoryNameArray:FEMALE];
    }
    
    if ([shared.selectedBtnTag isEqualToString:@"TakePhoto"] || [shared.selectedBtnTag isEqualToString:@"ChoosePhoto"]){
        [self loadUserCategoryNameAndGenderFromLocalDB];
    }else{
        [self loadUserCategoryNameAndGenderFromServer];
    }

}

- (void)viewWillDisappear:(BOOL)animated{
    ESCache *shared = [ESCache sharedCache];
    shared.selectedBtnTag = @"";
    shared.selectedUserStyleTagNames = nil;
    shared.selectedUserStyleTagNames = [selectedNameAry copy];
}
#pragma type of first navigation bar
- (void)firstNavigationBarShow{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelCategoryInfo)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveCategoryInfoToServer)];
    self.txtViewStyleGuide.text = @"Select the styles that match your look:";
}
#pragma type of second navigation bar
- (void)secondNavigationBarShow{
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(cancelCategoryInfo)];
    self.navigationItem.rightBarButtonItem = nil;//[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"StyleGuide", nil) style:UIBarButtonItemStyleDone target:self action:@selector(showStyleGuide)];
    self.txtViewStyleGuide.text = @"Select the styles that you wish to follow";
}

#pragma init category male or female name array
-(NSMutableArray *)getSelectedCategoryNameArray:(NSString *)selectedUserGender{
    
    NSMutableArray *arr_CategoryName = [[NSMutableArray alloc]init];
    
    if ([selectedUserGender isEqualToString:MALE]) {
        NSString *csvMaleNameFile = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:MAN_NAME_CSV_FILE ofType:CSV] encoding:NSUTF8StringEncoding error:nil];
        arr_CategoryName = [[csvMaleNameFile componentsSeparatedByString:@"\n"] mutableCopy];
    }else if ([selectedUserGender isEqualToString:FEMALE]){
        NSString *csvFemaleNameFile = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WOMEN_NAME_CSV_FILE ofType:CSV] encoding:NSUTF8StringEncoding error:nil];
        arr_CategoryName = [[csvFemaleNameFile componentsSeparatedByString:@"\n"] mutableCopy];
    }
    return arr_CategoryName;
}

#pragma  upload current user style name and style gender to server
- (void)uploadCategoryNameAndGenderToServer{
    
    ESCache *shared = [ESCache sharedCache];
    NSMutableArray *arr_CategoryNames = [[NSMutableArray alloc]init];
    for (int i = 0; i < self.arr_SelectedCategoryName.count - 1; i++) {
            BOOL isSelected = [self.arr_SelectedCategoryBool[i]boolValue];
            if (isSelected) {
                [arr_CategoryNames addObject:[self.arr_SelectedCategoryName objectAtIndex:i]];
            }else{
                NSLog(@"unselected index -- %d", i);
            }
    }
    
    PFUser *user = [PFUser currentUser];
    user[kESUserStyleKey] = arr_CategoryNames;
    
    if ([shared.selectedUserGender isEqualToString:@""] || shared.selectedUserGender == nil || [shared.selectedUserGender isEqualToString:@"(null)"]) {
        user[kESUserStyleGenderKey] = MALE;
    }
    if ([shared.selectedUserGender isEqualToString:MALE]){
        user[kESUserStyleGenderKey] = MALE;
    }
    if ([shared.selectedUserGender isEqualToString:FEMALE]){
        user[kESUserStyleGenderKey] = FEMALE;
    }
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"save category info successfully!");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"yourStyleUpdated" object:nil userInfo:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSLog(@"fail category info unfortunately!");
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
    }];
}
#pragma load current user style name and style gender from Local DB
- (void)loadUserCategoryNameAndGenderFromLocalDB{
    NSLog( @"category name count -- %lu", (unsigned long)self.arr_SelectedCategoryName.count);
    for (int i = 0; i<self.arr_SelectedCategoryName.count-1; i++) {
        [self.arr_SelectedCategoryBool addObject:[NSNumber numberWithBool:NO]];
    }
    [self.collectionView reloadData];
}
#pragma load current user style name and style gender from server
- (void)loadUserCategoryNameAndGenderFromServer{
    PFUser *currentUser = [PFUser currentUser];
    NSArray *categoryArray = [[NSArray alloc] init];
    categoryArray = [currentUser objectForKey:kESUserStyleKey];
    NSLog( @"category name count -- %lu", (unsigned long)self.arr_SelectedCategoryName.count);
    for (int i = 0; i<self.arr_SelectedCategoryName.count-1; i++) {
        
        [self.arr_SelectedCategoryBool addObject:[NSNumber numberWithBool:NO]];
        NSString *categoryLocalName  = [self.arr_SelectedCategoryName objectAtIndex:i];
        for (int j = 0; j<categoryArray.count; j++) {
            
            NSString *categoryServerName = [categoryArray objectAtIndex:j];
            if ([categoryLocalName isEqualToString:categoryServerName]) {
                [self.arr_SelectedCategoryBool replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
            }
        }
        
    }
    [self.collectionView reloadData];

}

- (void)showStyleGuide{
//    self.txtViewStyleGuide.text = @"Select the styles that you wish to follow";
}
- (void)saveCategoryInfoToServer{

   ESCache *shared = [ESCache sharedCache];
    if ([shared.selectedUserStyleTagName isEqualToString:@""] || shared.selectedUserStyleTagName == nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Message" message:@"Please Select Your Style In Style List" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PresentPhotoEditorVC" object:nil];
    }
   
}
- (void)cancelCategoryInfo{
    ESCache *shared = [ESCache sharedCache];
    PFUser *currentUser = [PFUser currentUser];
    NSString *currentUserId = [currentUser valueForKey:@"objectId"];
    if ([shared.selectedUserId isEqualToString:currentUserId]) {
        [self uploadCategoryNameAndGenderToServer];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.arr_SelectedCategoryName.count-1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ESCache *shared = [ESCache sharedCache];
    
    if ([shared.selectedBtnTag isEqualToString:@"TakePhoto"] || [shared.selectedBtnTag isEqualToString:@"ChoosePhoto"]) {
        if (selectedNumber == 0) {
            [self initSelectedCategoryBoolArray];
        }
        BOOL isSelected = [self.arr_SelectedCategoryBool[indexPath.row] boolValue];
        if (selectedNumber >= 2 && !isSelected) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"You can only define a maximum of two styles to your post. Selected styles can be pressed again to unselect them." delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
            [alert show];
            return;
        }
        self.arr_SelectedCategoryBool[indexPath.row] = [NSNumber numberWithBool:!isSelected];
        if (!isSelected) {
            selectedNumber += 1;
            [selectedNameAry addObject:[self.arr_SelectedCategoryName objectAtIndex:indexPath.row]];
            shared.selectedUserStyleTagName = [self.arr_SelectedCategoryName objectAtIndex:indexPath.row];
        } else {
            selectedNumber -= 1;
            [selectedNameAry removeObject:[self.arr_SelectedCategoryName objectAtIndex:indexPath.row]];
        }        
    }else{
        BOOL isSelected = [self.arr_SelectedCategoryBool[indexPath.row] boolValue];
        self.arr_SelectedCategoryBool[indexPath.row] = [NSNumber numberWithBool:!isSelected];
    }
    
    [collectionView reloadData];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ESCache *shared = [ESCache sharedCache];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellStyle" forIndexPath:indexPath];
    
    UIImageView *imgBG = (UIImageView *)[cell viewWithTag:100];
    NSString *strCategoryName = [self.arr_SelectedCategoryName objectAtIndex:indexPath.row];
    
    if ([shared.selectedUserGender isEqualToString:@""] || shared.selectedUserGender == nil || [shared.selectedUserGender isEqualToString:@"(null)"]) {
       imgBG.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",strCategoryName]];
    }else if ([shared.selectedUserGender isEqualToString:MALE]){
       imgBG.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",strCategoryName]];
    }else if ([shared.selectedUserGender isEqualToString:FEMALE]){
       imgBG.image = [UIImage imageNamed:[NSString stringWithFormat:@"w%@.png",strCategoryName]];
    }

    UILabel *label = (UILabel *)[cell viewWithTag:101];
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.5f];
    [label setTextAlignment:UITextAlignmentCenter];
    [label setText:strCategoryName];

    UIImageView *imgTick = (UIImageView *)[cell viewWithTag:102];
    imgTick.image = [UIImage imageNamed:@"tick.png"];
    
    //-----i button create-----//
    UIButton *btnIHelp = [[UIButton alloc]initWithFrame:CGRectMake(cell.frame.size.width/2+50, cell.frame.size.height/2+40, 28, 28)];
    [btnIHelp setBackgroundImage:[UIImage imageNamed:@"ihelp.png"] forState:UIControlStateNormal];
    [btnIHelp addTarget:self action:@selector(btnIHelpClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnIHelp.tag = indexPath.row + 100;
    [cell addSubview:btnIHelp];
    
    if (self.selectPossibleCategory == YES) {
        if ([shared.selectedBtnTag isEqualToString:@"TakePhoto"] || [shared.selectedBtnTag isEqualToString:@"ChoosePhoto"]) {
            if([self.arr_SelectedCategoryBool[indexPath.row] boolValue]){
                [imgTick setHidden:NO];
            }else{
                [imgTick setHidden:YES];
            }
        }else{
            if([self.arr_SelectedCategoryBool[indexPath.row] boolValue]){
                [imgTick setHidden:NO];
            }else{
                [imgTick setHidden:YES];
            }
        }
        
    }else if (self.selectPossibleCategory == NO){
        [imgTick setHidden:YES];
    }
    
    return cell;
}
#pragma init selectedCategoryBoolArray
- (void)initSelectedCategoryBoolArray{
    for (int i = 0; i<self.arr_SelectedCategoryName.count-1; i++){
         [self.arr_SelectedCategoryBool replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
    }
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(160, 140);
}

- (void)btnIHelpClicked:(UIButton *)sender{
    ESCache *shared = [ESCache sharedCache];
    shared.selectedStyleName = [self.arr_SelectedCategoryName objectAtIndex:sender.tag - 100];
    [self performSegueWithIdentifier:@"MyStyleSegue" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
