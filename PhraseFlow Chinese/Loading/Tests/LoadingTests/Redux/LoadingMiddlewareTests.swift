import Testing
@testable import Loading
@testable import LoadingMocks

final class LoadingMiddlewareTests {
    
    let mockEnvironment: MockLoadingEnvironment
    
    init() {
        mockEnvironment = MockLoadingEnvironment()
    }
    
    @Test(arguments: [
        LoadingStatus.complete,
        LoadingStatus.generatingDefinitions,
        LoadingStatus.generatingImage,
        LoadingStatus.generatingSpeech,
        LoadingStatus.none,
        LoadingStatus.writing
    ])
    func updateLoadingStatus(loadingStatus: LoadingStatus) async {
        let resultAction = await loadingMiddleware(
            .arrange,
            .updateLoadingStatus(loadingStatus),
            mockEnvironment
        )

        switch loadingStatus {
        case .complete:
            #expect(resultAction == .updateLoadingStatus(.none))
        case .writing,
                .generatingImage,
                .generatingSpeech,
                .generatingDefinitions,
                .none:
            #expect(resultAction == nil)
        }
    }
}
