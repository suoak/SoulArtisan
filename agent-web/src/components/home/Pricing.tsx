import React from 'react';
import './Pricing.css';

interface PackageTier {
  id: string;
  name: string;
  price: string;
  points: number;
  features: string[];
  popular?: boolean;
  contactOnly?: boolean;
}

const packageTiers: PackageTier[] = [
  {
    id: 'basic',
    name: '基础版',
    price: '1000',
    points: 20000,
    features: ['20,000 算力积分', '基础视频生成功能', '标准客服支持'],
  },
  {
    id: 'pro',
    name: '专业版',
    price: '2500',
    points: 60000,
    features: ['60,000 算力积分', '高清视频输出', '优先客服支持', '批量处理功能'],
    popular: true,
  },
  {
    id: 'enterprise',
    name: '企业版',
    price: '5000',
    points: 150000,
    features: ['150,000 算力积分', '4K超清输出', '专属客服支持', 'API接口访问', '团队协作功能'],
  },
  {
    id: 'custom',
    name: '商业版',
    price: '',
    points: 0,
    features: ['定制算力套餐', '私有化部署', '专属技术顾问', 'SLA服务保障', '定制开发支持'],
    contactOnly: true,
  },
];

const Pricing: React.FC = () => {
  return (
    <section id="pricing" className="pricing">
      <div className="pricing-container">
        <div className="section-title">
          <h2>充值套餐</h2>
          <p>灵活的算力套餐，满足不同规模的需求</p>
        </div>

        <div className="pricing-grid">
          {packageTiers.map((tier) => (
            <div
              key={tier.id}
              className={`pricing-card ${tier.popular ? 'popular' : ''} ${tier.contactOnly ? 'contact' : ''}`}
            >
              {tier.popular && <div className="card-badge">推荐</div>}
              {tier.contactOnly && <div className="card-badge contact">商业合作</div>}

              <div className="card-header">
                <h3>{tier.name}</h3>
                {tier.contactOnly ? (
                  <div className="price-contact">价格面议</div>
                ) : (
                  <div className="price">
                    <span className="price-symbol">¥</span>
                    <span className="price-value">{tier.price}</span>
                  </div>
                )}
                <p className="points">{tier.points > 0 ? `${tier.points.toLocaleString()} 积分` : ''}</p>
              </div>

              <ul className="features-list">
                {tier.features.map((feature, index) => (
                  <li key={index}>
                    <span className="check">✓</span>
                    {feature}
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Pricing;
