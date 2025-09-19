import Testing
@testable import Loading
@testable import LoadingMocks

final class LoadingMiddlewareTests {
    
    let mockEnvironment: MockLoadingEnvironment
    
    init() {
        mockEnvironment = MockLoadingEnvironment()
    }
    
    @Test
    func updateLoadingStatus_complete() async {
        let resultAction = await loadingMiddleware(
            .arrange,
            .updateLoadingStatus(.complete),
            mockEnvironment
        )

        #expect(resultAction == .updateLoadingStatus(.none))
    }
    
    @Test(arguments: [
        LoadingStatus.generatingDefinitions,
        LoadingStatus.generatingImage,
        LoadingStatus.generatingSpeech,
        LoadingStatus.none,
        LoadingStatus.writing
    ])
    func updateLoadingStatus_other(loadingStatus: LoadingStatus) async throws {
        let resultAction = await loadingMiddleware(
            .arrange,
            .updateLoadingStatus(loadingStatus),
            mockEnvironment
        )

        #expect(resultAction == nil)
    }
}
