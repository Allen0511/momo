//
//  ViewController.m
//  cell上添加tableview刷新
//
//  Created by 房中杰 on 16/8/8.
//  Copyright © 2016年 大街上的蚂蚁. All rights reserved.
//

#import "ViewController.h"
#import "bigCollectionViewCell.h"



@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *BigCollectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [_BigCollectionView registerNib:[UINib nibWithNibName:@"bigCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"bigCollectionViewCell"];
    
    _BigCollectionView.delegate = self;
    _BigCollectionView.dataSource = self;
    
    
}

#pragma mark --collectionView 代理
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return 20;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    bigCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bigCollectionViewCell" forIndexPath:indexPath];
    cell.lineNumber = [NSString stringWithFormat:@"%ld",(long)indexPath.item];
    
    return cell;
    
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(self.view.frame.size.width, 200);
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(10, 10, 10, 10);
    
}









- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
