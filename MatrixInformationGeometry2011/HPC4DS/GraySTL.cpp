// filename: GraySTL.cpp
// C++ code using the STL class vector
class Gray {
public:
    vector<int> code(int n) {
        vector<int> v;
        v.push_back(0);

        for(int i = 0; i < n; i++) {
            int h = 1 << i;
            int len = v.size();
            for(int j = len - 1; j >= 0; j--) {
                v.push_back(h + v[j]);
            }
        }
        return v;
    }
};
