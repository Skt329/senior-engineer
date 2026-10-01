# Testing Android apps: JUnit, coroutines, Flow, Room, Compose

## Commands
On Windows use `gradlew.bat`, elsewhere `./gradlew`:
- Unit tests: `gradlew testDebugUnitTest`
- Instrumented tests (device or emulator): `gradlew connectedDebugAndroidTest`
- One class: `gradlew testDebugUnitTest --tests "com.example.app.ui.home.HomeViewModelTest"`

## ViewModels
- Replace the main dispatcher with `Dispatchers.setMain(StandardTestDispatcher())` in a JUnit rule, and reset it after each test.
- Run tests in `runTest { }` and advance time with `advanceUntilIdle()`.
- Use fake repositories (small classes implementing the interface) rather than mocks when the fake is simple; use MockK where a fake would be large.
- Assert on emitted UI state:

```kotlin
@Test
fun showsErrorWhenLoadFails() = runTest {
    val viewModel = HomeViewModel(FakeHomeRepository(failWith = IOException()))
    viewModel.uiState.test {
        assertEquals(HomeUiState.Loading, awaitItem())
        assertTrue(awaitItem() is HomeUiState.Error)
    }
}
```

`test { }` comes from the Turbine library.

## Room
- Use an in-memory database (`Room.inMemoryDatabaseBuilder`) in instrumented tests.
- Test every migration with `MigrationTestHelper` and the exported schemas.

## Networking
- MockWebServer from OkHttp to test Retrofit services with recorded JSON responses, including error codes and timeouts.

## Compose UI
- `createComposeRule()` with semantics-based finders such as `onNodeWithText` and `onNodeWithContentDescription`.
- Test each state of a screen (loading, empty, error, content) by passing state directly to the stateless composable.
- Add test tags only where text or content descriptions cannot identify a node.

## Firebase
- Fake Firebase behind your own repository interfaces in unit tests. Use the Firebase Local Emulator Suite for integration tests of Firestore rules and Auth flows.
