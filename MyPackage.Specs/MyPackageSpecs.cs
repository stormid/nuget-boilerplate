using Machine.Specifications;

namespace MyPackage.Specs
{
    public class MyPackageSpecs
    {
        [Subject(typeof(MyPackage))]
        public class when_retrieving_awesomeness
        {
            private static MyPackage subject;
            private static bool result;

            Establish context = () => subject = new MyPackage();

            Because of = () => result = subject.Awesomeness();

            It should_be_awesome = () => result.ShouldBeTrue();
        }
    }
}