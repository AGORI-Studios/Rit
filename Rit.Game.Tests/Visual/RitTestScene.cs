using osu.Framework.Testing;

namespace Rit.Game.Tests.Visual
{
    public abstract partial class RitTestScene : TestScene
    {
        protected override ITestSceneTestRunner CreateRunner() => new RitTestSceneTestRunner();

        private partial class RitTestSceneTestRunner : RitGameBase, ITestSceneTestRunner
        {
            private TestSceneTestRunner.TestRunner runner;

            protected override void LoadAsyncComplete()
            {
                base.LoadAsyncComplete();
                Add(runner = new TestSceneTestRunner.TestRunner());
            }

            public void RunTestBlocking(TestScene test) => runner.RunTestBlocking(test);
        }
    }
}
