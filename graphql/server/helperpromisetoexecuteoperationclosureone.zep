namespace GraphQL\Server;

class HelperpromiseToExecuteOperationClosureOne
{
    private config;

    public function __construct(config)
    {
                let this->config = config;

    }

    public function __invoke(ExecutionResult result)
    {
    if this->config->getErrorsHandler() {
        result->setErrorsHandler(this->config->getErrorsHandler());
    }
    if this->config->getErrorFormatter() || this->config->getDebug() {
        result->setErrorFormatter(FormattedError::prepareFormatter(this->config->getErrorFormatter(), this->config->getDebug()));
    }
    return result;
    }
}
    