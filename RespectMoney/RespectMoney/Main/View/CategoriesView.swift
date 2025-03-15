//
//  CategoriesView.swift
//  RespectMoney
//
//  Created by Miguel Duran on 15-03-25.
//

import SwiftUI

struct CategoriesView: View {
    @AppStorage("categories") private var categories: String = "" // Store categories as CSV
    @State private var newCategory: String = "" // New category input
    
    var categoryList: [String] {
        categories.components(separatedBy: ",").filter { !$0.isEmpty } // Convert CSV to array
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Expense Categories")) {
                    HStack {
                        TextField("New Category", text: $newCategory)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.words)
                        
                        Button(action: addCategory) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(newCategory.isEmpty)
                    }
                    
                    List {
                        ForEach(categoryList, id: \.self) { category in
                            Text(category)
                        }
                        .onDelete(perform: deleteCategory)
                    }
                    
                    
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
    
    /// ✅ **Add a new category**
    private func addCategory() {
        var updatedCategories = categoryList
        if !updatedCategories.contains(newCategory) {
            updatedCategories.append(newCategory)
            categories = updatedCategories.joined(separator: ",") // Save updated categories
            newCategory = "" // Clear input field
        }
    }
    
    /// ✅ **Delete a category**
    private func deleteCategory(at offsets: IndexSet) {
        var updatedCategories = categoryList
        updatedCategories.remove(atOffsets: offsets)
        categories = updatedCategories.joined(separator: ",") // Save updated categories
    }
}

#Preview {
    CategoriesView()
}
