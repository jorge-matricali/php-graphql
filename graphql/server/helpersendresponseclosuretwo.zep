namespace GraphQL\Server;

class HelpersendResponseClosureTwo
{
    private exitWhenDone;

    public function __construct(exitWhenDone)
    {
                let this->exitWhenDone = exitWhenDone;

    }

    public function __invoke(actualResult)
    {
    this->doSendResponse(actualResult, this->exitWhenDone);
    }
}
    