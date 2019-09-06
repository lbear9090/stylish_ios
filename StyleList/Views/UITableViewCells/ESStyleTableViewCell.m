//
//  ESStyleTableViewCell.m
//  StyleList
//
//  Created by Lucky on 1/22/18.
//  Copyright © 2018 Eric Schanet. All rights reserved.
//

#import "ESStyleTableViewCell.h"
@interface ESStyleTableViewCell() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    
}

@end

@implementation ESStyleTableViewCell
@synthesize collectionView, m_nRow, m_aStyle;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [collectionView reloadData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(m_aStyle)
        return m_aStyle.count;
    return 0;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(120, 150);
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellStyle" forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell viewWithTag:101];
    label.text = m_aStyle[indexPath.row];
    return cell;
}
@end
