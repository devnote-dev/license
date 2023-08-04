require "spec"
require "../src/license"

describe License do
  it "raises on non-compiled licenses" do
    expect_raises(Exception) { License.licenses }
  end

  it "loads all licenses" do
    License.init
    License.licenses.size.should eq License::IDENTIFIERS.size
  end

  it "loads a license" do
    license = License.load "0bsd"

    license.title.should eq "BSD Zero Clause License"
    license.spdx_id.should eq "0BSD"
    license.nickname.should be_nil

    license.permissions.size.should eq 4
    license.conditions.should be_empty
    license.limitations.size.should eq 2
  end

  it "renders a license" do
    content = License.render "mit"

    content.should eq <<-LICENSE
      MIT License

      Copyright (c) <enter the year here> <enter the author here>

      Permission is hereby granted, free of charge, to any person obtaining a copy
      of this software and associated documentation files (the "Software"), to deal
      in the Software without restriction, including without limitation the rights
      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      copies of the Software, and to permit persons to whom the Software is
      furnished to do so, subject to the following conditions:
      
      The above copyright notice and this permission notice shall be included in all
      copies or substantial portions of the Software.
      
      THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
      SOFTWARE.
      LICENSE
  end
end
