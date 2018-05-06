namespace GraphQL\Server;

class HelpertoPsrResponseClosureFour
{
    private response;
    private writableBodyStream;

    public function __construct(response, writableBodyStream)
    {
                let this->response = response;
        let this->writableBodyStream = writableBodyStream;

    }

    public function __invoke(actualResult)
    {
    return this->doConvertToPsrResponse(actualResult, this->response, this->writableBodyStream);
    }
}
    