import AppKit
import Foundation

struct UsageWindow: Decodable {
    let used: Double
    let reset: ResetValue?
}

enum ResetValue: Decodable {
    case seconds(Double)
    case iso(String)

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        if let number = try? value.decode(Double.self) {
            self = .seconds(number)
        } else {
            self = .iso(try value.decode(String.self))
        }
    }

    var date: Date? {
        switch self {
        case .seconds(let value): return Date(timeIntervalSince1970: value)
        case .iso(let value):
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter.date(from: value) ?? ISO8601DateFormatter().date(from: value)
        }
    }
}

struct Provider: Decodable {
    let fiveHour: UsageWindow?
    let weekly: UsageWindow?
    let error: String?
}

struct Snapshot: Decodable {
    let claude: Provider
    let codex: Provider
    let fetchedAt: Double
}

final class UsageBar: NSObject, NSApplicationDelegate {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var snapshot: Snapshot?
    private var refreshing = false
    private var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        item.button?.toolTip = "Claude / Codex 使用量"
        render()
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    private func color(_ used: Double?) -> NSColor {
        guard let used else { return .secondaryLabelColor }
        if used >= 90 { return .systemRed }
        if used >= 70 { return .systemOrange }
        return .systemGreen
    }

    private func percentage(_ usage: UsageWindow?) -> String {
        guard let usage else { return "—" }
        return "\(Int(usage.used.rounded()))%"
    }

    private func append(_ text: String, color: NSColor, to title: NSMutableAttributedString) {
        title.append(NSAttributedString(string: text, attributes: [
            .foregroundColor: color,
            .font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium),
        ]))
    }

    private func menuRow(_ label: String, usage: UsageWindow?) -> NSMenuItem {
        let remaining = usage.map { " / 残り \(Int((100 - $0.used).rounded()))%" } ?? ""
        let reset = usage?.reset?.date.map {
            "  ↻ " + $0.formatted(date: .abbreviated, time: .shortened)
        } ?? ""
        let row = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        row.attributedTitle = NSAttributedString(string: "\(label): 使用 \(percentage(usage))\(remaining)\(reset)", attributes: [
            .foregroundColor: color(usage?.used),
            .font: NSFont.systemFont(ofSize: 13),
        ])
        return row
    }

    private func addProvider(_ name: String, _ provider: Provider, to menu: NSMenu) {
        let header = NSMenuItem(title: name, action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(menuRow("5時間", usage: provider.fiveHour))
        menu.addItem(menuRow("週間", usage: provider.weekly))
        if let error = provider.error {
            let row = NSMenuItem(title: error, action: nil, keyEquivalent: "")
            row.isEnabled = false
            menu.addItem(row)
        }
    }

    private func render() {
        let title = NSMutableAttributedString()
        let claude = snapshot?.claude
        let codex = snapshot?.codex
        append("C ", color: .labelColor, to: title)
        append("5h \(percentage(claude?.fiveHour))", color: color(claude?.fiveHour?.used), to: title)
        append("  W \(percentage(claude?.weekly))", color: color(claude?.weekly?.used), to: title)
        append("  │  X ", color: .labelColor, to: title)
        append("5h \(percentage(codex?.fiveHour))", color: color(codex?.fiveHour?.used), to: title)
        append("  W \(percentage(codex?.weekly))", color: color(codex?.weekly?.used), to: title)
        item.button?.attributedTitle = title

        let menu = NSMenu()
        if let snapshot {
            addProvider("Claude", snapshot.claude, to: menu)
            menu.addItem(.separator())
            addProvider("Codex", snapshot.codex, to: menu)
            menu.addItem(.separator())
            let updated = Date(timeIntervalSince1970: snapshot.fetchedAt)
            let row = NSMenuItem(title: "更新: \(updated.formatted(date: .omitted, time: .shortened))", action: nil, keyEquivalent: "")
            row.isEnabled = false
            menu.addItem(row)
        } else {
            let row = NSMenuItem(title: "取得中…", action: nil, keyEquivalent: "")
            row.isEnabled = false
            menu.addItem(row)
        }
        menu.addItem(.separator())
        let refresh = NSMenuItem(title: "今すぐ更新", action: #selector(refreshNow), keyEquivalent: "r")
        refresh.target = self
        refresh.isEnabled = !refreshing
        menu.addItem(refresh)
        let quit = NSMenuItem(title: "終了", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
        item.menu = menu
    }

    @objc private func refreshNow() { refresh() }
    @objc private func quit() { NSApp.terminate(nil) }

    private func refresh() {
        guard !refreshing else { return }
        refreshing = true
        render()
        let helper = Bundle.main.resourceURL!.appendingPathComponent("usage.py")
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process.arguments = [helper.path]
        process.environment = ProcessInfo.processInfo.environment.merging([
            "PATH": NSHomeDirectory() + "/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin",
        ]) { _, new in new }
        let output = Pipe()
        process.standardOutput = output
        process.standardError = Pipe()
        process.terminationHandler = { [weak self] task in
            let data = output.fileHandleForReading.readDataToEndOfFile()
            let parsed = task.terminationStatus == 0 ? try? JSONDecoder().decode(Snapshot.self, from: data) : nil
            DispatchQueue.main.async {
                self?.refreshing = false
                if let parsed { self?.snapshot = parsed }
                self?.render()
            }
        }
        do {
            try process.run()
        } catch {
            refreshing = false
            render()
        }
    }
}

let app = NSApplication.shared
let delegate = UsageBar()
app.delegate = delegate
app.run()
