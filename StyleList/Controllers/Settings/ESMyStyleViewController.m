//
//  ESMyStyleViewController.m
//  Style List
//
//  Created by 123 on 2/7/18.
//  Copyright © 2018 ClearView Webdesign Ltd. All rights reserved.
//

#import "ESMyStyleViewController.h"

@interface ESMyStyleViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imgPhotoStyle;
@property (weak, nonatomic) IBOutlet UITextView *textViewInfo;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *arr_SelectedCategoryAllDetailName;
@property (strong, nonatomic) NSMutableArray *arr_SelectedCategoryDetailName;

@property (strong, nonatomic) NSMutableDictionary *dictDetailCategory;
//@property (strong, nonatomic) NSArray *imagesData;
@end

@implementation ESMyStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSFontAttributeName:[UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:21]}];
    id barButtonAppearance = [UIBarButtonItem appearance];
    NSDictionary *barButtonTextAttributes = @{
                                              UITextAttributeFont: [UIFont fontWithName:GTWALSHEIM_REGULAR_FONT size:15.0f],
                                              UITextAttributeTextShadowColor: [UIColor blackColor],
                                              UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]
                                              };
    
    [barButtonAppearance setTitleTextAttributes:barButtonTextAttributes
                                       forState:UIControlStateNormal];

    ESCache *shared = [ESCache sharedCache];
    //===========init selected all detail name ==============//
    self.arr_SelectedCategoryAllDetailName = [[NSMutableArray alloc]init];
    self.arr_SelectedCategoryAllDetailName = [self getSelectedCategoryDetailNameArray];
    self.arr_SelectedCategoryDetailName = [[NSMutableArray alloc]init];
    self.arr_SelectedCategoryDetailName = [self getSelectedCategoryDetailName:shared.selectedStyleName];
    
    
    NSInteger categoryCount = self.arr_SelectedCategoryDetailName.count;
    
    self.textViewInfo.text = [self readCategoryHelpText:shared.selectedStyleName];

    [self setupScrollViewImages];

    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    
    self.pageControl.numberOfPages = categoryCount;
    [self.pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

#pragma init category detail name array
-(NSMutableArray *)getSelectedCategoryDetailNameArray{
    
    ESCache *shared = [ESCache sharedCache];
    NSMutableArray *arr_CategoryDetailName = [[NSMutableArray alloc]init];
    
    if ([shared.selectedUserGender isEqualToString:@""] || shared.selectedUserGender == nil || [shared.selectedUserGender isEqualToString:@"(null)"]) {
        NSString *csvMaleNameFile = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:MAN_DETAIL_NAME_CSV_FILE ofType:CSV] encoding:NSUTF8StringEncoding error:nil];
        arr_CategoryDetailName = [[csvMaleNameFile componentsSeparatedByString:@"\n"] mutableCopy];
    }else if ([shared.selectedUserGender isEqualToString:MALE]){
        NSString *csvMaleNameFile = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:MAN_DETAIL_NAME_CSV_FILE ofType:CSV] encoding:NSUTF8StringEncoding error:nil];
        arr_CategoryDetailName = [[csvMaleNameFile componentsSeparatedByString:@"\n"] mutableCopy];
    }else if ([shared.selectedUserGender isEqualToString:FEMALE]){
        NSString *csvFemaleNameFile = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:WOMEN_DETAIL_NAME_CSV_FILE ofType:CSV] encoding:NSUTF8StringEncoding error:nil];
        arr_CategoryDetailName = [[csvFemaleNameFile componentsSeparatedByString:@"\n"] mutableCopy];
    }

    return arr_CategoryDetailName;
}

- (NSMutableArray *)getSelectedCategoryDetailName:(NSString *)selectedCategoryName{
    
    NSMutableArray *selectedNameArray = [[NSMutableArray alloc]init];
    if (self.arr_SelectedCategoryAllDetailName.count > 0) {
        for (int i = 0; i<self.arr_SelectedCategoryAllDetailName.count - 1; i++) {
            NSString *str = [self.arr_SelectedCategoryAllDetailName objectAtIndex:i];
            if ([str length] > 0) {
                str = [str substringToIndex:[str length] - 1];
                if ([selectedCategoryName isEqualToString:str]) {
                    [selectedNameArray addObject:[self.arr_SelectedCategoryAllDetailName objectAtIndex:i]];
                }
            } else {
                NSLog(@"error");
            }
        }
    }else{
        NSLog(@"error");
    }
    return selectedNameArray;
}

#pragma mark - ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scroll enable--");
    NSInteger pageIndex = scrollView.contentOffset.x /CGRectGetWidth(scrollView.frame);
    self.pageControl.currentPage = pageIndex;
    switch (pageIndex) {
        case 0:
            NSLog(@"indexbig--%ld", (long)pageIndex);
            break;
        case 1:
            NSLog(@"indexbig--%ld", (long)pageIndex);
            break;
        case 2:
            NSLog(@"indexbig--%ld", (long)pageIndex);
            break;
        case 3:
            NSLog(@"indexbig--%ld", (long)pageIndex);
            break;
        case 4:
            NSLog(@"indexbig--%ld", (long)pageIndex);
            break;
        default:
            break;
    }
}

-(NSString *)readCategoryHelpText:(NSString*)strNum
{
    ESCache *shared = [ESCache sharedCache];
    NSString *fileName = @"";
    if ([shared.selectedUserGender isEqualToString:@""] || shared.selectedUserGender == nil || [shared.selectedUserGender isEqualToString:@"(null)"]) {
       fileName = [[NSBundle mainBundle] pathForResource:MAN_CATEGORY_HELP ofType:STRINGS];
    }else if ([shared.selectedUserGender isEqualToString:MALE]){
       fileName = [[NSBundle mainBundle] pathForResource:MAN_CATEGORY_HELP ofType:STRINGS];
    }else if ([shared.selectedUserGender isEqualToString:FEMALE]){
       fileName = [[NSBundle mainBundle] pathForResource:WOMEN_CATEGORY_HELP ofType:STRINGS];
    }
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fileName];
    NSString *content = [dict objectForKey:strNum];
    return content;
}

- (void)setupScrollViewImages
{
    ESCache *shared = [ESCache sharedCache];
    for (int i = 0; i<self.arr_SelectedCategoryDetailName.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.scrollView.frame) * i, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame))];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        NSString *selectedDetailImg = [self.arr_SelectedCategoryDetailName objectAtIndex:i];
        
        if (i == 0) {
            if ([selectedDetailImg length]>0) {
                
                selectedDetailImg = [selectedDetailImg substringToIndex:[selectedDetailImg length]-1];
                
                if ([shared.selectedUserGender isEqualToString:@""] || shared.selectedUserGender == nil || [shared.selectedUserGender isEqualToString:@"(null)"]) {
                   imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",selectedDetailImg]];
                }else if ([shared.selectedUserGender isEqualToString:MALE]){
                   imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",selectedDetailImg]];
                }else if ([shared.selectedUserGender isEqualToString:FEMALE]){
                   imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"w%@.png",selectedDetailImg]];
                }
            }
        }else{
            if ([shared.selectedUserGender isEqualToString:@""] || shared.selectedUserGender == nil || [shared.selectedUserGender isEqualToString:@"(null)"]) {
                imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",selectedDetailImg]];
            }else if ([shared.selectedUserGender isEqualToString:MALE]){
                imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",selectedDetailImg]];
            }else if ([shared.selectedUserGender isEqualToString:FEMALE]){
                imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"w%@.png",selectedDetailImg]];
            }
        }
        
        [self.scrollView addSubview:imageView];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.arr_SelectedCategoryDetailName.count, self.scrollView.frame.size.height);
}

#pragma mark - pagecontrol method
-(void)pageTurn:(UIPageControl *) page
{
    NSInteger pageTag = page.currentPage;
    switch (pageTag) {
        case 0:
            
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
