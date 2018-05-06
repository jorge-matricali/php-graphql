namespace GraphQL\Error;

class FormattedErrorprepareFormatterClosureTwo
{
    private formatter;
    private debug;

    public function __construct(formatter, debug)
    {
                let this->formatter = formatter;
        let this->debug = debug;

    }

    public function __invoke(e)
    {
    return FormattedError::addDebugEntries({this->formatter}(e), e, this->debug);
    }
}
    