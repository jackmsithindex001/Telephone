//
//  ContactMatchingIndex.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

public final class ContactMatchingIndex {
    private let index: [String: MatchedContact]

    public init(contacts: Contacts, maxPhoneNumberLength: Int) {
        index = makeMap(from: contacts, maxPhoneNumberLength: maxPhoneNumberLength)
    }

    public func contact(forAddress address: String) -> MatchedContact? {
        return index[address]
    }
}

private func makeMap(from contacts: Contacts, maxPhoneNumberLength: Int) -> [String: MatchedContact] {
    var result: [String: MatchedContact] = [:]
    contacts.enumerate { contact in
        update(&result, withPhonesOf: contact, maxPhoneNumberLength: maxPhoneNumberLength)
        update(&result, withEmailsOf: contact)
    }
    return result
}

private func update(_ map: inout [String: MatchedContact], withPhonesOf contact: Contact, maxPhoneNumberLength: Int) {
    contact.phones.forEach {
        map[NormalizedPhoneNumber($0.number, maxLength: maxPhoneNumberLength).value] = MatchedContact(
            name: contact.name, address: .phone(number: $0.number, label: $0.label)
        )
    }
}

private func update(_ map: inout [String: MatchedContact], withEmailsOf contact: Contact) {
    contact.emails.forEach {
        map[$0.address] = MatchedContact(name: contact.name, address: .email(address: $0.address, label: $0.label))
    }
}
