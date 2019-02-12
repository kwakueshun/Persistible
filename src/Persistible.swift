/// Persistible.swift

import Foundation

protocol Persistible {
    static var fileName: String { get }
}

extension Persistible {

    static var archiveUrl: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("json")
    }

    static func deleteFile() {
        _ = try? FileManager.default.removeItem(at: archiveUrl)
    }
}

enum PersistenceData<T: Persistible> {
    case single(T)
    case array([T])
}

extension Persistible where Self: Codable {

    static func getEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }

    static func getDecoder() -> JSONDecoder {
        return JSONDecoder()
    }
}



extension Persistible where Self: Codable & Hashable {

    func saveToFile() throws {

        /// Tried appending to a single dict
        do {
            let existent = try Self.loadFromFile()
            if existent != self {
                let list = [existent, self]
                try list.saveToFile()
            }
        }
            /// Could not decode because found an array instead of a single object 
        catch DecodingError.typeMismatch(_, _) {

            if var existent = try? Self.loadListFromFile(), !existent.contains(self) {
                existent.append(self)
                try existent.saveToFile()
            }
        }
        /// Could not decode because data is in wrong format as there is no file yet
        catch {
            let encoder = Self.getEncoder()
            let encoded = try encoder.encode(self)
            try encoded.write(to: Self.archiveUrl, options: [])
        }

    }

    static func loadFromFile() throws -> Self {
        let decoder = Self.getDecoder()
        let retrieved = try Data(contentsOf: Self.archiveUrl)
        let decoded = try decoder.decode(Self.self, from: retrieved)
        return decoded
    }

    static func loadListFromFile() throws -> [Self] {
        let decoder = Self.getDecoder()
        let retrieved = try Data(contentsOf: Self.archiveUrl)
        let decoded = try decoder.decode([Self].self, from: retrieved)
        return decoded
    }

    static func load(completion: @escaping (PersistenceData<Self>) -> Void) throws {

        do {
            let data = try loadFromFile()
            completion(.single(data))
        }
        catch DecodingError.typeMismatch(_, _) {
            let data = try loadListFromFile()
            completion(.array(data))
        }
    }
}


extension Array where Element: Persistible & Codable & Hashable {

    func saveToFile() throws {
        guard count > 0 else { return }
        var copy = self

        if let existentArray = try? Element.loadListFromFile(), existentArray.count > 0 {
            copy.append(contentsOf: existentArray)
            let unique = Set<Element>(copy)
            copy = Array(unique)
        }
        let encoded = try Element.getEncoder().encode(copy)
        try encoded.write(to: Element.archiveUrl, options: [])
    }
}

