import Foundation

/// Utility class for working with credit card numbers.
@objc(OMSCardNumber) public final class CardNumber: NSObject {
    
    /**
     Normalize credit card number by removing all non-number characters.
     - returns: String of normalized credit card number. eg. *4242424242424242*
     */
    @objc public static func normalize(pan: String) -> String {
        return pan.stringByReplacingOccurrencesOfString(
            "[^0-9]",
            withString: "",
            options: .RegularExpressionSearch,
            range: nil)
    }
    
    /**
     Determine credit card brand from given credit card number.
     - returns: valid `CardBrand` or nil if it cannot be determined.
     - seealso: CardBrand
     */
    public static func brand(pan: String) -> CardBrand? {
        return CardBrand.all
            .filter({ (brand) -> Bool in pan.rangeOfString(brand.pattern, options: .RegularExpressionSearch, range: nil, locale: nil) != nil })
            .first
    }
    
    @objc(brandForPan:) public static func __brand(pan: String) -> Int {
        return brand(pan)?.rawValue ?? NSNotFound
    }
    
    
    /**
     Formats given credit card number into a human-friendly string by inserting spaces
     after every 4 digits. ex. `4242 4242 4242 4242`
     - returns: Formatted credit card number string.
     */
    @objc public static func format(pan: String) -> String {
        var result = ""
        for (i, digit) in normalize(pan).characters.enumerate() {
            if i > 0 && i % 4 == 0 {
                result += " "
            }
            
            result.append(digit)
        }
        
        return result
    }
    
    /**
     Validate credit card number using the Luhn algorithm.
     - returns: `true` if the Luhn check passes, otherwise `false`.
     */
    @objc public static func luhn(pan: String) -> Bool {
        let chars = normalize(pan).characters
        let digits = chars
            .reverse()
            .map { (char) -> Int in Int(String(char)) ?? -1 }
        
        guard !digits.contains(-1) else { return false }
        
        let oddSum = digits.enumerate()
            .filter { (index, digit) -> Bool in index % 2 == 0 }
            .map { (index, digit) -> Int in digit }
        let evenSum = digits.enumerate()
            .filter { (index, digit) -> Bool in index % 2 != 0 }
            .map { (index, digit) -> Int in digit * 2 }
            .map { (sum) -> Int in sum > 9 ? sum - 9 : sum }
        
        let sum = (oddSum + evenSum).reduce(0) { (acc, digit) -> Int in acc + digit }
        return sum % 10 == 0
    }
    
    /**
     Validate credit card number by using the Luhn algorithm and checking that the length
     is within credit card brand's valid range.
     - returns: `true` if the given credit card number is valid for all available checks, otherwise `false`.
     */
    @objc public static func validate(pan: String) -> Bool {
        let normalized = normalize(pan)
        
        guard let brand = brand(normalized) else { return false }
        return brand.validLengths ~= normalized.characters.count && luhn(normalized)
    }
}
