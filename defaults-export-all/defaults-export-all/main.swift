// Douglas Hill, January 2017

import Foundation

enum ErrorCases: Error {
    case couldNotReadString
}

func lauchedDefaultsProcess(withArguments args: [String]) -> Process {
    let process = Process()
    process.launchPath = "/usr/bin/defaults"
    process.arguments = args
    process.standardOutput = Pipe()
    process.standardError = Pipe()

    process.launch()

    return process
}

extension Process {
    func readAllOutputString() throws -> String {
        let output = readAllOutputData()

        guard let outString = String(data: output, encoding: .utf8) else {
            throw ErrorCases.couldNotReadString
        }
        
        return outString
    }

    func readAllOutputData() -> Data {
        let outputPipe = self.standardOutput as! Pipe

        return outputPipe.fileHandleForReading.readDataToEndOfFile()
    }
}

func doStuff() {
    let repoURL = URL(fileURLWithPath: "/Users/Douglas/Development/SyncedPreferences/", isDirectory: true)

    let blacklist = try! Set(NSString(contentsOf: repoURL.appendingPathComponent("blacklist.txt", isDirectory: false), encoding: 4).components(separatedBy: .newlines))

    let allDomainsString = try! lauchedDefaultsProcess(withArguments: ["domains"]).readAllOutputString().trimmingCharacters(in: .whitespacesAndNewlines)
    let domains = allDomainsString.components(separatedBy: ", ").filter { blacklist.contains($0) == false }

    let syncedPrefs = repoURL.appendingPathComponent("data", isDirectory: true)

    for domain in domains {
        let process = lauchedDefaultsProcess(withArguments: ["export", domain, "-"])
        let plistData = process.readAllOutputData()

        try! plistData.write(to: syncedPrefs.appendingPathComponent(domain, isDirectory: false).appendingPathExtension("plist"))
    }
}

doStuff()
