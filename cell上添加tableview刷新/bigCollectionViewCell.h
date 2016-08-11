//
//  bigCollectionViewCell.h
//  cell上添加tableview刷新
//
//  Created by 房中杰 on 16/8/8.
//  Copyright © 2016年 大街上的蚂蚁. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface bigCollectionViewCell : UICollectionViewCell<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *smallCollectionView;

@property(nonatomic,copy)NSString *lineNumber;


@end
