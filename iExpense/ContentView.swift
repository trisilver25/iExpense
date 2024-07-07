//
//  ContentView.swift
//  iExpense
//
//  Created by Tristin Smith on 6/18/24.
//

import Observation
import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: ExpenseType
    let amount: Double
}

enum ExpenseType: Codable {
    case business
    case personal
    
    var description: String {
        switch self {
        case .business:
            "Business"
        case .personal:
            "Personal"
        }
    }
}

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    
    @State private var showingAddExpense = false
    
    var body: some View {
        NavigationStack {
            HStack(alignment: .top, spacing: 0) {
                ExpenseColumnView(type: .personal, expenses: personalExpenses)
                Rectangle()
                    .fill(.gray)
                    .frame(width: 1)
                ExpenseColumnView(type: .business, expenses: businessExpenses)
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("Add Expense", systemImage: "plus") {
                    showingAddExpense = true
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddView(expenses: expenses)
        }
    }
    
    private var businessExpenses: [ExpenseItem] {
        Expenses().items
            .filter { $0.type == .business}
            .compactMap{ $0 }
    }
    
    private var personalExpenses: [ExpenseItem] {
        Expenses().items
            .filter { $0.type == .personal}
            .compactMap{ $0 }
    }
    
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}

struct ExpenseColumnView: View {
    let type: ExpenseType
    let expenses: [ExpenseItem]
    
    var body: some View {
        VStack {
            Text(type.description)
                .font(.largeTitle)
                .bold()
            Rectangle()
                .fill(.gray)
                .frame(height: 1)
            
            LazyVStack(alignment: .leading) {
                ForEach(expenses) { expense in
                    ExpenseItemView(expense: expense)
                    Divider()
                }
            }
            
        }
    }
}

struct ExpenseItemView: View {
    let expense: ExpenseItem
    
    var format: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(expense.name)
                .font(.headline)
            Text(expense.amount, format: format)
                .foregroundStyle(setColor(of: expense))
        }
        .padding(.horizontal, 8)
    }
    
    func setColor(of item: ExpenseItem) -> Color {
        if item.amount >= 100 {
            return Color.red
        } else if item.amount < 100 && item.amount > 10 {
            return Color.blue
        } else {
            return Color.primary
        }
    }
}


#Preview {
    ContentView()
}
