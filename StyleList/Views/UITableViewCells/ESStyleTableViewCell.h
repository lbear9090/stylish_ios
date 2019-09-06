//
//  ESStyleTableViewCell.h
//  StyleList
//
//  Created by Lucky on 1/22/18.
//  Copyright © 2018 Eric Schanet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESStyleTableViewCell : UITableViewCell
{
    
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, readwrite) int m_nRow;
@property (nonatomic, readwrite) NSArray *m_aStyle;
@end
