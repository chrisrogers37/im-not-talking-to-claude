import SwiftUI

struct PopoverContentView: View {
    @ObservedObject var viewModel: INTTCViewModel

    var body: some View {
        if viewModel.needsSetup {
            SetupView(viewModel: viewModel)
        } else {
            mainView
        }
    }

    private var mainView: some View {
        VStack(spacing: 0) {
            MasterToggleView(
                isHidden: viewModel.isHidden,
                sessionCount: viewModel.sessions.count,
                onToggle: viewModel.toggleMaster
            )

            Divider().opacity(0.3)

            SessionCatalogView(
                sessions: viewModel.sessions,
                isHidden: viewModel.isHidden
            )

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: 10))
                    .foregroundColor(INTTCTheme.exposed)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider().opacity(0.3)

            SettingsView(killOnHide: $viewModel.killOnHide)

            Divider().opacity(0.3)

            FooterView(
                launchAtLogin: $viewModel.launchAtLogin,
                onQuit: viewModel.quit
            )
        }
        .frame(width: 320)
        .fixedSize(horizontal: false, vertical: true)
        .background(INTTCTheme.surface)
    }
}
