namespace GraphQL\Server;

class HelperpromiseToExecuteOperationClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(RequestError err)
    {
    return Error::createLocatedError(err, null, null);
    }
}
    