//
//  CategoryItemsViewModel.swift
//  Core
//
//  Created by Atilla Özder on 4.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import Foundation

class CategoryItemsViewModel: ImageViewModel {
    
    private var category: Category!
    
    var navigationTitle: String {
        return category.name
    }
    
    override init() {
        super.init()
    }
    
    convenience init(category: Category) {
        self.init()
        self.category = category
    }
    
    override func getPageRequest() -> URLRequestConfigurable? {
        return Router.categoryItems(categoryId: category.id, page: input.currentPage)
    }
}
