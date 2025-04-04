import Foundation


extension Double {
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        return formatter
    }
    
    func toCurrancy() -> String {
        return currencyFormatter.string(for: self ) ?? ""
    }
    
    private var distanceFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 1
        
        return formatter
    }
    
    func distancelMilesString() -> String {
        return distanceFormatter.string(for: self / 1600 ) ?? ""
    }
    
}
