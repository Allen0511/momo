//
//  bigCollectionViewCell.m
//  cell上添加tableview刷新
//
//  Created by 房中杰 on 16/8/8.
//  Copyright © 2016年 大街上的蚂蚁. All rights reserved.
//

#import "bigCollectionViewCell.h"
#import "smallCollectionViewCell.h"

@implementation bigCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [_smallCollectionView registerNib:[UINib nibWithNibName:@"smallCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"smallCollectionViewCell"];
    _smallCollectionView.delegate =self;
    _smallCollectionView.dataSource = self;
    
}

-(void)setLineNumber:(NSString *)lineNumber
{


    _lineNumber = lineNumber;
    
    [_smallCollectionView reloadData];
    
}

#pragma mark --collectionView 代理
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return 10;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    smallCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"smallCollectionViewCell" forIndexPath:indexPath];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@行%ld个",_lineNumber,(long)indexPath.item];
    
    
    return cell;
    
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(100, 180);
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(10, 10, 10, 10);
    
}

@end
