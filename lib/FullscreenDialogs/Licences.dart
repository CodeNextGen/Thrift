import 'package:flutter/material.dart';

import 'package:thrift/Instances/Theme.dart';

class Licenses extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Licences"),
      ),
      body: ListView(
        shrinkWrap: false,
        children: <Widget>[
          LicenceWidget(
            licenceName: "Flutter",
            licenceLink: "https://github.com/flutter/flutter/blob/master/LICENSE",
            licenceText: "Copyright 2014 The Chromium Authors. All rights reserved."
            + "\n\nRedistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:"
            + "\n\nRedistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer."
            + "\n\nRedistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution."
            + "\n\nNeither the name of Google Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission."
            + '\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.'
            ,
          ),
          LicenceWidget(
            licenceName: "Roboto Font",
            licenceLink: "https://github.com/google/roboto/blob/master/LICENSE",
            licenceText: "Copyright 2019 Dark and Jeweled" + '\n\nLicensed under the Apache License, Version 2.0 (the "License");'+"\nyou may not use this file except in compliance with the License."+"\nYou may obtain a copy of the License at"+"\n\nhttp://www.apache.org/licenses/LICENSE-2.0"+"\n\nUnless required by applicable law or agreed to in writing, software"+'\ndistributed under the License is distributed on an "AS IS" BASIS,'+"\nWITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied."+"\nSee the License for the specific language governing permissions and"+"\nlimitations under the License.",
          ),
          LicenceWidget(
            licenceName: "Material Icons",
            licenceLink: "https://github.com/google/material-design-icons/blob/master/LICENSE",
            licenceText: "Copyright 2019 Dark and Jeweled" + '\n\nLicensed under the Apache License, Version 2.0 (the "License");'+"\nyou may not use this file except in compliance with the License."+"\nYou may obtain a copy of the License at"+"\n\nhttp://www.apache.org/licenses/LICENSE-2.0"+"\n\nUnless required by applicable law or agreed to in writing, software"+'\ndistributed under the License is distributed on an "AS IS" BASIS,'+"\nWITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied."+"\nSee the License for the specific language governing permissions and"+"\nlimitations under the License.",
          ),
          LicenceWidget(
            licenceName: "intl",
            licenceLink: "https://github.com/purus/launch_review/blob/master/LICENSE",
            licenceText: 'Copyright 2013, the Dart project authors. All rights reserved. Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:'
            + "\n\nRedistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer."
            + "\n\nRedistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution."
            + "\n\nNeither the name of Google Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission."
            + '\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.'
            ,
          ),
          LicenceWidget(
            licenceName: "launch_review",
            licenceLink: "https://github.com/purus/launch_review/blob/master/LICENSE",
            licenceText: 'The MIT License \n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
          ),
          LicenceWidget(
            licenceName: "path_provider",
            licenceLink: "https://github.com/flutter/plugins/blob/master/packages/path_provider/LICENSE",
            licenceText: 'Copyright 2017, the Flutter project authors. All rights reserved. Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:'
                + "\n\nRedistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer."
                + "\n\nRedistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution."
                + "\n\nNeither the name of Google Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission."
                + '\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.'
            ,
          ),
          LicenceWidget(
            licenceName: "sqflite",
            licenceLink: "https://github.com/tekartik/sqflite/blob/master/LICENSE",
            licenceText: 'BSD 2-Clause License\n\nCopyright (c) 2019, Tekartik\nAll rights reserved.\n\nRedistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:'
            + "\n\nRedistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer."
            + "\n\nRedistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution."
            + '\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.'
            ,
          ),
          LicenceWidget(
            licenceName: "shared_preferences",
            licenceLink: "https://github.com/flutter/plugins/blob/master/packages/shared_preferences/LICENSE",
            licenceText: "Copyright 2017 The Chromium Authors. All rights reserved."
                + "\n\nRedistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:"
                + "\n\nRedistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer."
                + "\n\nRedistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution."
                + "\n\nNeither the name of Google Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission."
                + '\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.'
            ,
          ),
          LicenceWidget(
            licenceName: "flutter_local_notifications",
            licenceLink: "https://github.com/MaikuB/flutter_local_notifications/blob/master/LICENSE",
            licenceText: "Copyright 2018 Michael Bui. All rights reserved."
                + "\n\nRedistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:"
                + "\n\nRedistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer."
                + "\n\nRedistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution."
                + "\n\nNeither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission."
                + '\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.'
            ,
          ),
          LicenceWidget(
            licenceName: "url_launcher",
            licenceLink: "https://github.com/flutter/plugins/blob/master/packages/url_launcher/LICENSE",
            licenceText: "Copyright 2017 The Chromium Authors. All rights reserved."
                + "\n\nRedistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:"
                + "\n\nRedistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer."
                + "\n\nRedistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution."
                + "\n\nNeither the name of Google Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission."
                + '\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.'
            ,
          ),
          LicenceWidget(
            licenceName: "keyboard_visibility",
            licenceLink: "https://github.com/adee42/flutter_keyboard_visibility/blob/master/LICENSE",
            licenceText: "The MIT License"
                + "\n\nCopyright (c) 2006-2018\nAll rights reserved."
                + '\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:'
                + "\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software."
                + '\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
            ,
          ),
          LicenceWidget(
            licenceName: "flutter_statusbarcolor",
            licenceLink: "https://github.com/mchome/flutter_statusbarcolor/blob/master/LICENSE",
            licenceText: "MIT License"
                + "\n\nCopyright (c) 2018 fuyumi"
                + '\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:'
                + "\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software."
                + '\n\nTHE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
            ,
          ),
        ],
      ),
    );
  }
}

class LicenceWidget extends StatelessWidget{
  static const Color licenseContainerColor = Color(0xffcfd8dc);

  final String licenceText;
  final String licenceName;
  final String licenceLink;
  LicenceWidget({@required this.licenceText, @required this.licenceLink, @required this.licenceName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Flex(
        crossAxisAlignment: CrossAxisAlignment.start,
        direction: Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flex(
            direction: Axis.vertical,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 2),
                child: Text(licenceName, style: const TextStyle(fontSize: 16, color: primaryText),),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 2),
                child: Text(licenceLink, style: const TextStyle(fontSize: 12, color: wiki_link),),
              ),
            ],
          ),
          Container(
            color: licenseContainerColor,
            padding: const EdgeInsets.all(8),
            child: Text(licenceText, style: const TextStyle(fontSize: 14, color: primaryText),),
          ),
        ],
      ),
    );
  }
}