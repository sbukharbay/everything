//
//  SelfEmploymentType.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 27/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public enum SelfEmploymentType: String, Codable {
    case trader = "SOLE_TRADER"
    case contractor = "CONTRACTOR"
    case partner = "BUSINESS_PARTNER"
    case llp = "LIMITED_LIABILITY_PARTNER"
    case shareHolder = "PLC_SHAREHOLDER"
    case director = "LIMITED_COMPANY_DIRECTOR"
    
    public func getText() -> String {
        var status = ""
        
        switch self {
        case .trader:
            status = "Sole Trader"
        case .contractor:
            status = "Contractor"
        case .partner:
            status = "Business Partner"
        case .llp:
            status = "Limited Liability Partner (LLP)"
        case .shareHolder:
            status = "Private Limited Company Share Holder (20% or greater)"
        case .director:
            status = "Limited Company Director"
        }
        return status
    }
}
